class KDBongkarModel {
  final String noProcKD;
  final int noRuangKD;
  final String tglMasuk;
  final String? tglKeluar;

  KDBongkarModel({
    required this.noProcKD,
    required this.noRuangKD,
    required this.tglMasuk,
    this.tglKeluar,
  });

  factory KDBongkarModel.fromJson(Map<String, dynamic> json) {
    return KDBongkarModel(
      noProcKD: json['NoProcKD'],
      noRuangKD: json['NoRuangKD'], // int
      tglMasuk: json['TglMasuk'] ?? '-',
      tglKeluar: json['TglKeluar'] ?? '-', // bisa null
    );
  }
}
