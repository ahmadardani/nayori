class JTPair {
  final int number;
  final String level;
  final String type;
  final String japanese;
  final String translation;

  JTPair({
    required this.number,
    required this.level,
    required this.type,
    required this.japanese,
    required this.translation,
  });

  factory JTPair.fromJson(Map<String, dynamic> json) {
    return JTPair(
      number: json['number'] ?? 0,
      level: json['level'] ?? '',
      type: json['type'] ?? '',
      japanese: json['japanese'] ?? '',
      translation: json['translation'] ?? '',
    );
  }
}