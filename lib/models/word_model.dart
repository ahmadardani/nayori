import 'dart:convert';

class WordData {
  final String kanji;
  final String foundInCharacters;
  final String foundInMeaning;
  final String foundInReading;

  WordData({
    required this.kanji,
    required this.foundInCharacters,
    required this.foundInMeaning,
    required this.foundInReading,
  });

  factory WordData.fromJson(Map<String, dynamic> json) {
    return WordData(
      kanji: json['kanji'] ?? '',
      foundInCharacters: json['Found_in_Characters'] ?? '',
      foundInMeaning: json['Found_in_Meaning'] ?? '',
      foundInReading: json['Found_in_Reading'] ?? '',
    );
  }
}

class WordParsedResult {
  final List<WordData> allWords;
  final List<String> uniqueKanjis;

  WordParsedResult({required this.allWords, required this.uniqueKanjis});
}

WordParsedResult parseWordDataInBackground(String jsonString) {
  final List<dynamic> parsedJson = json.decode(jsonString);
  final allWords = parsedJson.map((json) => WordData.fromJson(json)).toList();
  final uniqueKanjis = allWords.map((e) => e.kanji).toSet().toList();
  
  return WordParsedResult(allWords: allWords, uniqueKanjis: uniqueKanjis);
}