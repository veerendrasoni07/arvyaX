class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.createdAt,
    required this.ambienceId,
    required this.ambienceTitle,
    required this.mood,
    required this.text,
  });

  final String id;
  final DateTime createdAt;
  final String ambienceId;
  final String ambienceTitle;
  final String mood;
  final String text;

  factory JournalEntry.fromMap(Map<dynamic, dynamic> map) {
    return JournalEntry(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      ambienceId: map['ambienceId'] as String,
      ambienceTitle: map['ambienceTitle'] as String,
      mood: map['mood'] as String,
      text: map['text'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'ambienceId': ambienceId,
      'ambienceTitle': ambienceTitle,
      'mood': mood,
      'text': text,
    };
  }
}

