import 'package:just_audio/just_audio.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> configureLoopingAsset(String assetPath) async {
    await _player.setLoopMode(LoopMode.one);
    await _player.setAsset(assetPath);
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> stop() => _player.stop();

  Future<void> dispose() => _player.dispose();
}

