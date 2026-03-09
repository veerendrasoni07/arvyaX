class SessionSnapshot {
  const SessionSnapshot({
    required this.ambienceId,
    required this.elapsedSeconds,
    required this.totalSeconds,
    required this.isPlaying,
    required this.updatedAt,
  });

  final String ambienceId;
  final int elapsedSeconds;
  final int totalSeconds;
  final bool isPlaying;
  final DateTime updatedAt;

  factory SessionSnapshot.fromMap(Map<dynamic, dynamic> map) {
    return SessionSnapshot(
      ambienceId: map['ambienceId'] as String,
      elapsedSeconds: map['elapsedSeconds'] as int,
      totalSeconds: map['totalSeconds'] as int,
      isPlaying: map['isPlaying'] as bool,
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ambienceId': ambienceId,
      'elapsedSeconds': elapsedSeconds,
      'totalSeconds': totalSeconds,
      'isPlaying': isPlaying,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

