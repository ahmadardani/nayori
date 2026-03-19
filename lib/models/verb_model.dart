import 'dart:convert';

class VerbData {
  final String group;
  final String subGroup;
  final String kanji;
  final String dictionary;
  final String naiForm;
  final String taForm;
  final String nakattaForm;
  final String teForm;
  final String meaning;

  VerbData({
    required this.group,
    required this.subGroup,
    required this.kanji,
    required this.dictionary,
    required this.naiForm,
    required this.taForm,
    required this.nakattaForm,
    required this.teForm,
    required this.meaning,
  });

  factory VerbData.fromJson(Map<String, dynamic> json) {
    return VerbData(
      group: json['Group'] ?? '',
      subGroup: json['Sub_Group'] ?? '',
      kanji: json['Kanji'] ?? '',
      dictionary: json['Dictionary'] ?? '',
      naiForm: json['Nai_form'] ?? '',
      taForm: json['Ta_form'] ?? '',
      nakattaForm: json['Nakatta_form'] ?? '',
      teForm: json['Te_form'] ?? '',
      meaning: json['Meaning'] ?? '',
    );
  }
}

class VerbParsedResult {
  final List<VerbData> allVerbs;
  final Map<String, List<String>> groupedSubGroups; 

  VerbParsedResult({required this.allVerbs, required this.groupedSubGroups});
}

VerbParsedResult parseVerbDataInBackground(String jsonString) {
  final List<dynamic> parsedJson = json.decode(jsonString);
  final allVerbs = parsedJson.map((json) => VerbData.fromJson(json)).toList();
  
  Map<String, Set<String>> tempGroups = {};
  for (var verb in allVerbs) {
    if (!tempGroups.containsKey(verb.group)) {
      tempGroups[verb.group] = {};
    }
    tempGroups[verb.group]!.add(verb.subGroup);
  }
  
  Map<String, List<String>> groupedSubGroups = {};
  tempGroups.forEach((key, value) {
    groupedSubGroups[key] = value.toList();
  });

  return VerbParsedResult(allVerbs: allVerbs, groupedSubGroups: groupedSubGroups);
}