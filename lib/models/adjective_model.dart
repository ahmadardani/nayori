import 'dart:convert';

class AdjectiveData {
  final String category;
  final String level;
  final String vocabulary;
  final String translation;

  AdjectiveData({
    required this.category,
    required this.level,
    required this.vocabulary,
    required this.translation,
  });

  factory AdjectiveData.fromJson(Map<String, dynamic> json) {
    return AdjectiveData(
      category: json['category']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      vocabulary: json['vocabulary']?.toString() ?? '',
      translation: json['translation']?.toString() ?? '',
    );
  }
}

List<AdjectiveData> parseAdjectiveDataInBackground(String jsonString) {
  final List<dynamic> parsedJson = json.decode(jsonString);
  return parsedJson.map((json) => AdjectiveData.fromJson(json)).toList();
}