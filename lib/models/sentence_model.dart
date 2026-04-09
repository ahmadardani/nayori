// lib/models/sentence_model.dart

class SentencePairData {
  final int level;
  final String type;
  final int no;
  final String japanese;
  final String indonesian;

  SentencePairData({
    required this.level,
    required this.type,
    required this.no,
    required this.japanese,
    required this.indonesian,
  });

  factory SentencePairData.fromJson(Map<String, dynamic> json) {
    return SentencePairData(
      level: json['Level'] ?? 0,
      type: json['Type']?.toString() ?? '',
      no: json['No'] ?? 0,
      japanese: json['Japanese']?.toString() ?? '',
      indonesian: json['Indonesian']?.toString() ?? '',
    );
  }
}