import 'package:hive_flutter/hive_flutter.dart';

import '../data/models/session_snapshot.dart';

class StorageService {
  static const _sessionBox = 'session_state';
  static const _sessionKey = 'active_session';

  late final Box _session;

  Future<void> init() async {
    await Hive.initFlutter();
    _session = await Hive.openBox(_sessionBox);
  }

  SessionSnapshot? loadSession() {
    final data = _session.get(_sessionKey);
    if (data == null) {
      return null;
    }
    return SessionSnapshot.fromMap(data as Map<dynamic, dynamic>);
  }

  Future<void> saveSession(SessionSnapshot snapshot) {
    return _session.put(_sessionKey, snapshot.toMap());
  }

  Future<void> clearSession() {
    return _session.delete(_sessionKey);
  }
}

