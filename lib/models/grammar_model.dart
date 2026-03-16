import 'dart:convert';

class GrammarData {
  final String chapter;
  final String number;
  final String sentence;
  final String translation;

  GrammarData({
    required this.chapter,
    required this.number,
    required this.sentence,
    required this.translation,
  });

  factory GrammarData.fromJson(Map<String, dynamic> json) {
    return GrammarData(
      chapter: json['chapter'] ?? '',
      number: json['number']?.toString() ?? '',
      sentence: json['sentence'] ?? '',
      translation: json['translation'] ?? '',
    );
  }
}

class GrammarParsedResult {
  final List<GrammarData> allGrammar;
  final List<String> uniqueChapters;

  GrammarParsedResult({required this.allGrammar, required this.uniqueChapters});
}

GrammarParsedResult parseGrammarDataInBackground(String jsonString) {
  final List<dynamic> parsedJson = json.decode(jsonString);
  final allGrammar = parsedJson.map((json) => GrammarData.fromJson(json)).toList();
  final uniqueChapters = allGrammar.map((e) => e.chapter).toSet().toList();
  
  return GrammarParsedResult(allGrammar: allGrammar, uniqueChapters: uniqueChapters);
}