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
  final String masuForm;
  final String potential;
  final String volitional;
  final String teKudasai;
  final String teIru;
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
    required this.masuForm,
    required this.potential,
    required this.volitional,
    required this.teKudasai,
    required this.teIru,
    required this.meaning,
  });

  factory VerbData.fromJson(Map<String, dynamic> json) {
    return VerbData(
      group: json['Group']?.toString() ?? '',
      subGroup: json['Sub_Group']?.toString() ?? '',
      kanji: json['Kanji']?.toString() ?? '',
      dictionary: json['Dictionary']?.toString() ?? '',
      naiForm: json['Nai_form']?.toString() ?? '',
      taForm: json['Ta_form']?.toString() ?? '',
      nakattaForm: json['Nakatta_form']?.toString() ?? '',
      teForm: json['Te_form']?.toString() ?? '',
      masuForm: json['Masu_form']?.toString() ?? '',
      potential: json['Potential']?.toString() ?? '',
      volitional: json['Volitional']?.toString() ?? '',
      teKudasai: json['Te_kudasai']?.toString() ?? '',
      teIru: json['Te_iru']?.toString() ?? '',
      meaning: json['Meaning']?.toString() ?? '',
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