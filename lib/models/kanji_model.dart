class KanjiData {
  final String level;
  final int no;
  final String kanji;
  final String example;
  final String readMeaning;

  KanjiData({
    required this.level,
    required this.no,
    required this.kanji,
    required this.example,
    required this.readMeaning,
  });

  factory KanjiData.fromJson(Map<String, dynamic> json) {
    return KanjiData(
      level: json['level'],
      no: json['no'],
      kanji: json['kanji'],
      example: json['example'],
      readMeaning: json['read_meaning'],
    );
  }
}