import 'dart:convert';

class RenshuuData {
  final String chapter;
  final String number;
  final String sentence;
  final String translation;

  RenshuuData({
    required this.chapter,
    required this.number,
    required this.sentence,
    required this.translation,
  });

  factory RenshuuData.fromJson(Map<String, dynamic> json) {
    return RenshuuData(
      chapter: json['chapter']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      sentence: json['sentence']?.toString() ?? '',
      translation: json['translation']?.toString() ?? '',
    );
  }
}

class RenshuuParsedResult {
  final List<RenshuuData> allData;
  final List<String> uniqueChapters;

  RenshuuParsedResult({required this.allData, required this.uniqueChapters});
}

RenshuuParsedResult parseRenshuuDataInBackground(String jsonString) {
  final List<dynamic> parsedJson = json.decode(jsonString);
  final allData = parsedJson.map((json) => RenshuuData.fromJson(json)).toList();
  final uniqueChapters = allData.map((e) => e.chapter).toSet().toList();
  
  return RenshuuParsedResult(allData: allData, uniqueChapters: uniqueChapters);
}