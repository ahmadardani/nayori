import 'dart:convert';

class JlptSoal {
  final String idSoal;
  final bool isContoh;
  final String pertanyaan;
  final String? terjemahanSoal; // <-- Tambahan Baru
  final List<String> pilihan;
  final int jawabanBenar;

  JlptSoal({
    required this.idSoal,
    required this.isContoh,
    required this.pertanyaan,
    this.terjemahanSoal, // <-- Tambahan Baru
    required this.pilihan,
    required this.jawabanBenar,
  });

  factory JlptSoal.fromJson(Map<String, dynamic> json) {
    return JlptSoal(
      idSoal: json['id_soal'] ?? '',
      isContoh: json['is_contoh'] ?? false,
      pertanyaan: json['pertanyaan'] ?? '',
      terjemahanSoal: json['terjemahan_soal'], // <-- Tambahan Baru
      pilihan: List<String>.from(json['pilihan'] ?? []),
      jawabanBenar: json['jawaban_benar'] ?? 0,
    );
  }
}

class JlptMondai {
  final int nomorMondai;
  final String instruksi;
  final String? teksBacaan;
  final String? terjemahanBacaan; // <-- Tambahan Baru
  final List<JlptSoal> soalList;

  JlptMondai({
    required this.nomorMondai,
    required this.instruksi,
    this.teksBacaan,
    this.terjemahanBacaan, // <-- Tambahan Baru
    required this.soalList,
  });

  factory JlptMondai.fromJson(Map<String, dynamic> json) {
    var list = json['soal_list'] as List? ?? [];
    return JlptMondai(
      nomorMondai: json['nomor_mondai'] ?? 0,
      instruksi: json['instruksi'] ?? '',
      teksBacaan: json['teks_bacaan'],
      terjemahanBacaan: json['terjemahan_bacaan'], // <-- Tambahan Baru
      soalList: list.map((i) => JlptSoal.fromJson(i)).toList(),
    );
  }
}

class JlptSesi {
  final String idSesi;
  final String namaSesi;
  final List<JlptMondai> mondaiList;

  JlptSesi({
    required this.idSesi,
    required this.namaSesi,
    required this.mondaiList,
  });

  factory JlptSesi.fromJson(Map<String, dynamic> json) {
    var list = json['mondai_list'] as List? ?? [];
    return JlptSesi(
      idSesi: json['id_sesi'] ?? '',
      namaSesi: json['nama_sesi'] ?? '',
      mondaiList: list.map((i) => JlptMondai.fromJson(i)).toList(),
    );
  }
}

class JlptData {
  final int tahun;
  final int bulan;
  final String level;
  final List<JlptSesi> sesi;

  JlptData({
    required this.tahun,
    required this.bulan,
    required this.level,
    required this.sesi,
  });

  factory JlptData.fromJson(Map<String, dynamic> json) {
    var list = json['sesi'] as List? ?? [];
    return JlptData(
      tahun: json['tahun'] ?? 0,
      bulan: json['bulan'] ?? 0,
      level: json['level'] ?? '',
      sesi: list.map((i) => JlptSesi.fromJson(i)).toList(),
    );
  }
}

List<JlptData> parseJlptDataInBackground(String jsonString) {
  final List<dynamic> parsedJson = json.decode(jsonString);
  return parsedJson.map((json) => JlptData.fromJson(json)).toList();
}