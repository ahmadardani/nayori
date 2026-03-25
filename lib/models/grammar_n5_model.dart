import 'dart:convert';

class GrammarN5Sentence {
  final String japanese;
  final String indonesian;
  final String romaji; 

  GrammarN5Sentence({
    required this.japanese,
    required this.indonesian,
    this.romaji = '',
  });
}

class GrammarN5Data {
  final String id;
  final String title;
  final String explanationFile;
  final List<GrammarN5Sentence> quizSentences;

  GrammarN5Data({
    required this.id,
    required this.title,
    required this.explanationFile,
    required this.quizSentences,
  });
}


List<GrammarN5Data> parseGrammarN5DataInBackground(String tsvString) {

  final List<String> lines = const LineSplitter().convert(tsvString);
  
  if (lines.isEmpty) return [];

  Map<String, GrammarN5Data> groupedData = {};

  for (int i = 1; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) continue; 

    final parts = line.split('\t');

    if (parts.length >= 4) {
      final String id = parts[0].trim();
      final String title = parts[1].trim();
      final String japanese = parts[2].trim();
      final String translation = parts[3].trim();
      final String explanationFile = parts.length > 4 ? parts[4].trim() : '';

      final sentence = GrammarN5Sentence(
        japanese: japanese,
        indonesian: translation,
      );

      if (!groupedData.containsKey(id)) {
        groupedData[id] = GrammarN5Data(
          id: id,
          title: title,
          explanationFile: explanationFile, 
          quizSentences: [sentence],
        );
      } else {

        groupedData[id]!.quizSentences.add(sentence);
        
        if (groupedData[id]!.explanationFile.isEmpty && explanationFile.isNotEmpty) {
 
        }
      }
    }
  }

  return groupedData.values.toList();
}