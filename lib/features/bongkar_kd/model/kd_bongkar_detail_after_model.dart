import 'kd_bongkar_detail_model.dart';

class KDBongkarDetailAfterModel {
  final String noProcKD;
  final String noST;
  final String dateCreate;
  final String idLokasi;

  // Tambahan field baru (optional - tidak break existing code)
  final List<DetailItem>? details;
  final String? labelM3;
  final int? labelJumlah;

  KDBongkarDetailAfterModel({
    required this.noProcKD,
    required this.noST,
    required this.dateCreate,
    required this.idLokasi,
    this.details,
    this.labelM3,
    this.labelJumlah,
  });

  factory KDBongkarDetailAfterModel.fromJson(Map<String, dynamic> json) {
    return KDBongkarDetailAfterModel(
      noProcKD: json['NoProcKD'] ?? '',
      noST: json['NoST'] ?? '',
      dateCreate: json['DateCreate'] ?? '-',
      idLokasi: json['IdLokasi'] ?? '-',
      // Field baru - kalau ada di response, ambil. Kalau tidak, null.
      details: json['Details'] != null
          ? (json['Details'] as List).map((item) => DetailItem.fromJson(item)).toList()
          : null,
      labelM3: json['LabelM3'],
      labelJumlah: json['LabelJumlah'],
    );
  }
}