import 'dart:convert';

class DetailPilihan {
  final String teks;
  final String arti;
  final String? penjelasan;
  final bool isBenar;

  DetailPilihan({required this.teks, required this.arti, this.penjelasan, required this.isBenar});

  factory DetailPilihan.fromJson(Map<String, dynamic> json) {
    return DetailPilihan(
      teks: json['teks'] ?? '',
      arti: json['arti'] ?? '',
      penjelasan: json['penjelasan'],
      isBenar: json['is_benar'] ?? false,
    );
  }
}

class KosaKata {
  final String kanji;
  final String hiragana;
  final String arti;

  KosaKata({required this.kanji, required this.hiragana, required this.arti});

  factory KosaKata.fromJson(Map<String, dynamic> json) {
    return KosaKata(
      kanji: json['kanji'] ?? '',
      hiragana: json['hiragana'] ?? '',
      arti: json['arti'] ?? '',
    );
  }
}

class Grammar {
  final String pola;
  final String penjelasan;
  final List<String> contoh;

  Grammar({required this.pola, required this.penjelasan, required this.contoh});

  factory Grammar.fromJson(Map<String, dynamic> json) {
    return Grammar(
      pola: json['pola'] ?? '',
      penjelasan: json['penjelasan'] ?? '',
      contoh: List<String>.from(json['contoh'] ?? []),
    );
  }
}

class Pembahasan {
  final List<DetailPilihan> detailPilihan;
  final List<KosaKata> kosaKata;
  final List<Grammar> grammar;

  Pembahasan({required this.detailPilihan, required this.kosaKata, required this.grammar});

  factory Pembahasan.fromJson(Map<String, dynamic> json) {
    return Pembahasan(
      detailPilihan: (json['detail_pilihan'] as List?)?.map((i) => DetailPilihan.fromJson(i)).toList() ?? [],
      kosaKata: (json['kosa_kata'] as List?)?.map((i) => KosaKata.fromJson(i)).toList() ?? [],
      grammar: (json['grammar'] as List?)?.map((i) => Grammar.fromJson(i)).toList() ?? [],
    );
  }
}

class JlptSoal {
  final String idSoal;
  final bool isContoh;
  final String pertanyaan;
  final String? terjemahanSoal;
  final List<String> pilihan;
  final int jawabanBenar;
  final Pembahasan? pembahasan; // <-- Tambahan Baru

  JlptSoal({
    required this.idSoal,
    required this.isContoh,
    required this.pertanyaan,
    this.terjemahanSoal,
    required this.pilihan,
    required this.jawabanBenar,
    this.pembahasan, // <-- Tambahan Baru
  });

  factory JlptSoal.fromJson(Map<String, dynamic> json) {
    return JlptSoal(
      idSoal: json['id_soal'] ?? '',
      isContoh: json['is_contoh'] ?? false,
      pertanyaan: json['pertanyaan'] ?? '',
      terjemahanSoal: json['terjemahan_soal'],
      pilihan: List<String>.from(json['pilihan'] ?? []),
      jawabanBenar: json['jawaban_benar'] ?? 0,
      pembahasan: json['pembahasan'] != null ? Pembahasan.fromJson(json['pembahasan']) : null, // <-- Tambahan Baru
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