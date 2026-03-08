import 'dart:convert';

class KanjiData {
  final String level;
  final int no;
  final String kanji;
  final String example;
  final String readMeaning;
  final String exampleLower; 

  KanjiData({
    required this.level,
    required this.no,
    required this.kanji,
    required this.example,
    required this.readMeaning,
    required this.exampleLower,
  });

  factory KanjiData.fromJson(Map<String, dynamic> json) {
    final String exampleText = json['example'] ?? '';
    return KanjiData(
      level: json['level'] ?? '',
      no: json['no'] ?? 0,
      kanji: json['kanji'] ?? '',
      example: exampleText,
      readMeaning: json['read_meaning'] ?? '',
      exampleLower: exampleText.toLowerCase(),
    );
  }
}

class KanjiParsedResult {
  final List<KanjiData> allData;
  final List<String> uniqueKanjis;

  KanjiParsedResult({required this.allData, required this.uniqueKanjis});
}

KanjiParsedResult parseKanjiDataInBackground(String jsonString) {
  final List<dynamic> parsedJson = json.decode(jsonString);
  final allData = parsedJson.map((json) => KanjiData.fromJson(json)).toList();
  final uniqueKanjis = allData.map((e) => e.kanji).toSet().toList();
  
  return KanjiParsedResult(allData: allData, uniqueKanjis: uniqueKanjis);
}