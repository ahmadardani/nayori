import 'dart:convert';

class GrammarN5Sentence {
  final String indonesian;
  final String english;
  final String japanese;
  final String romaji;

  GrammarN5Sentence({
    required this.indonesian,
    required this.english,
    required this.japanese,
    required this.romaji,
  });

  factory GrammarN5Sentence.fromJson(Map<String, dynamic> json) {
    return GrammarN5Sentence(
      indonesian: json['indonesian'] ?? '',
      english: json['english'] ?? '',
      japanese: json['japanese'] ?? '',
      romaji: json['romaji'] ?? '',
    );
  }
}

class GrammarN5Data {
  final String id;
  final String title;
  final String meaningId;
  final String meaningEn;
  final String explanationFile;
  final List<GrammarN5Sentence> quizSentences;

  GrammarN5Data({
    required this.id,
    required this.title,
    required this.meaningId,
    required this.meaningEn,
    required this.explanationFile,
    required this.quizSentences,
  });

  factory GrammarN5Data.fromJson(Map<String, dynamic> json) {
    var list = json['quiz_sentences'] as List? ?? [];
    List<GrammarN5Sentence> sentencesList = list.map((i) => GrammarN5Sentence.fromJson(i)).toList();

    return GrammarN5Data(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      meaningId: json['meaning_id'] ?? '',
      meaningEn: json['meaning_en'] ?? '',
      explanationFile: json['explanation_file'] ?? '',
      quizSentences: sentencesList,
    );
  }
}

List<GrammarN5Data> parseGrammarN5DataInBackground(String jsonString) {
  final dynamic parsedJson = json.decode(jsonString);
  if (parsedJson is List) {
    return parsedJson.map((json) => GrammarN5Data.fromJson(json)).toList();
  } else if (parsedJson is Map) {
    return [GrammarN5Data.fromJson(parsedJson as Map<String, dynamic>)];
  }
  return [];
}