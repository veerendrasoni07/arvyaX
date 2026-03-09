class Ambience {
  const Ambience({
    required this.id,
    required this.title,
    required this.tag,
    required this.durationMinutes,
    required this.image,
    required this.description,
    required this.sensoryChips,
  });

  final String id;
  final String title;
  final String tag;
  final int durationMinutes;
  final String image;
  final String description;
  final List<String> sensoryChips;

  factory Ambience.fromJson(Map<String, dynamic> json) {
    return Ambience(
      id: json['id'] as String,
      title: json['title'] as String,
      tag: json['tag'] as String,
      durationMinutes: json['durationMinutes'] as int,
      image: json['image'] as String,
      description: json['description'] as String,
      sensoryChips: (json['sensoryChips'] as List<dynamic>)
          .map((chip) => chip as String)
          .toList(),
    );
  }

  Duration get duration => Duration(minutes: durationMinutes);
}

