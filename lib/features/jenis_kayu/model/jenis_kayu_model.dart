// lib/features/jenis_kayu/model/jenis_kayu.dart
class JenisKayu {
  final int idJenisKayu;
  final String jenis;
  final String? singkatan;
  const JenisKayu({required this.idJenisKayu, required this.jenis, this.singkatan});

  factory JenisKayu.fromJson(Map<String, dynamic> m) => JenisKayu(
    idJenisKayu: m['idJenisKayu'] is num ? (m['idJenisKayu'] as num).toInt() : int.tryParse('${m['idJenisKayu']}') ?? 0,
    jenis: m['jenis']?.toString() ?? '',
    singkatan: m['singkatan']?.toString(),
  );

  @override
  String toString() => (singkatan == null || singkatan!.isEmpty) ? jenis : '$jenis (${singkatan!})';
}
