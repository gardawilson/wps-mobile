// lib/features/qc_sawmill/model/qc_sawmill_header.dart
class QcSawmillHeader {
  final String noQc;
  final String tgl;          // "YYYY-MM-DD"
  final int? idJenisKayu;
  final String? namaJenisKayu;
  final int? meja;           // <— ubah ke int?
  final String? namaMeja;

  QcSawmillHeader({
    required this.noQc,
    required this.tgl,
    this.idJenisKayu,
    this.namaJenisKayu,
    this.meja,
    this.namaMeja
  });

  factory QcSawmillHeader.fromJson(Map<String, dynamic> j) => QcSawmillHeader(
    noQc: j['noQc']?.toString() ?? '',
    tgl: j['tgl']?.toString() ?? '',
    idJenisKayu: (j['idJenisKayu'] is num)
        ? (j['idJenisKayu'] as num).toInt()
        : int.tryParse(j['idJenisKayu']?.toString() ?? ''),
    namaJenisKayu: j['namaJenisKayu']?.toString(),
    meja: (j['meja'] is num)
        ? (j['meja'] as num).toInt()
        : int.tryParse(j['meja']?.toString() ?? ''),
    namaMeja: j['namaMeja']?.toString(),

  );
}