import 'dart:convert';

class CompoundVerbExample {
  final String japanese;
  final String indonesian;

  CompoundVerbExample({required this.japanese, required this.indonesian});

  factory CompoundVerbExample.fromJson(Map<String, dynamic> json) {
    return CompoundVerbExample(
      japanese: json['japanese']?.toString() ?? '',
      indonesian: json['indonesian']?.toString() ?? '',
    );
  }
}

class CompoundVerbData {
  final int id;
  final String pattern;
  final String meaning;
  final List<CompoundVerbExample> examples;

  CompoundVerbData({
    required this.id,
    required this.pattern,
    required this.meaning,
    required this.examples,
  });

  factory CompoundVerbData.fromJson(Map<String, dynamic> json) {
    var list = json['examples'] as List;
    List<CompoundVerbExample> exampleList = list.map((i) => CompoundVerbExample.fromJson(i)).toList();

    return CompoundVerbData(
      id: json['id'] ?? 0,
      pattern: json['pattern']?.toString() ?? '',
      meaning: json['meaning']?.toString() ?? '',
      examples: exampleList,
    );
  }
}

List<CompoundVerbData> parseCompoundVerbs(String jsonString) {
  final List<dynamic> parsedJson = json.decode(jsonString);
  return parsedJson.map((json) => CompoundVerbData.fromJson(json)).toList();
}