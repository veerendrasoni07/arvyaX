import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/ambience.dart';
import '../../data/models/session_snapshot.dart';
import '../../services/audio_service.dart';
import '../../services/storage_service.dart';

class PlayerController extends ChangeNotifier {
  PlayerController({
    required AudioService audioService,
    required StorageService storageService,
  })  : _audioService = audioService,
        _storageService = storageService;

  final AudioService _audioService;
  final StorageService _storageService;
  final String _audioAsset = 'assets/audio/ambient_loop.wav';

  Timer? _timer;
  Ambience? _current;
  Ambience? _pendingReflection;
  Duration _elapsed = Duration.zero;
  Duration _total = Duration.zero;
  bool _isPlaying = false;

  Ambience? get current => _current;
  Duration get elapsed => _elapsed;
  Duration get total => _total;
  bool get isPlaying => _isPlaying;

  bool get hasActiveSession =>
      _current != null && _elapsed < _total && _total > Duration.zero;

  Future<void> restore(List<Ambience> ambiences) async {
    final snapshot = _storageService.loadSession();
    if (snapshot == null) {
      return;
    }

    final ambience = ambiences.where((e) => e.id == snapshot.ambienceId).firstOrNull;
    if (ambience == null) {
      await _storageService.clearSession();
      return;
    }

    var elapsed = snapshot.elapsedSeconds;
    if (snapshot.isPlaying) {
      elapsed += DateTime.now().difference(snapshot.updatedAt).inSeconds;
    }

    if (elapsed >= snapshot.totalSeconds) {
      _pendingReflection = ambience;
      await _storageService.clearSession();
      notifyListeners();
      return;
    }

    _current = ambience;
    _elapsed = Duration(seconds: elapsed);
    _total = Duration(seconds: snapshot.totalSeconds);
    _isPlaying = snapshot.isPlaying;

    await _audioService.configureLoopingAsset(_audioAsset);
    if (_isPlaying) {
      await _audioService.play();
    }
    _startTimer();
    notifyListeners();
  }

  Future<void> start(Ambience ambience) async {
    _current = ambience;
    _elapsed = Duration.zero;
    _total = ambience.duration;
    _isPlaying = true;

    await _audioService.configureLoopingAsset(_audioAsset);
    await _audioService.play();
    _startTimer();
    await _persist();
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (!hasActiveSession) return;
    _isPlaying = !_isPlaying;
    if (_isPlaying) {
      await _audioService.play();
    } else {
      await _audioService.pause();
    }
    await _persist();
    notifyListeners();
  }

  Future<void> seekTo(double seconds) async {
    if (!hasActiveSession) return;
    _elapsed = Duration(seconds: seconds.clamp(0, _total.inSeconds).toInt());
    if (_elapsed >= _total) {
      await _completeSession();
      return;
    }
    await _persist();
    notifyListeners();
  }

  Future<void> endManually() async {
    _pendingReflection = _current;
    await _stop(clearReflection: false);
    notifyListeners();
  }

  Ambience? consumePendingReflection() {
    final value = _pendingReflection;
    _pendingReflection = null;
    return value;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!_isPlaying) return;
      _elapsed += const Duration(seconds: 1);
      if (_elapsed >= _total) {
        await _completeSession();
        return;
      }
      await _persist();
      notifyListeners();
    });
  }

  Future<void> _completeSession() async {
    _pendingReflection = _current;
    await _stop(clearReflection: false);
    notifyListeners();
  }

  Future<void> _stop({required bool clearReflection}) async {
    _timer?.cancel();
    _timer = null;
    await _audioService.stop();
    if (clearReflection) _pendingReflection = null;
    _current = null;
    _elapsed = Duration.zero;
    _total = Duration.zero;
    _isPlaying = false;
    await _storageService.clearSession();
  }

  Future<void> _persist() {
    if (_current == null || !hasActiveSession) {
      return _storageService.clearSession();
    }
    final snapshot = SessionSnapshot(
      ambienceId: _current!.id,
      elapsedSeconds: _elapsed.inSeconds,
      totalSeconds: _total.inSeconds,
      isPlaying: _isPlaying,
      updatedAt: DateTime.now(),
    );
    return _storageService.saveSession(snapshot);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

