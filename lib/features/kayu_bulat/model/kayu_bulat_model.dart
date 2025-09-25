class KayuBulatModel {
  final String noKayuBulat;
  final String noPlat;
  final int idJenisKayu;
  final int idSupplier;
  final int idPengukuran;
  final String noTruk;
  final String jenisTruk;
  final String dateCreate;
  final int pengurangan;
  final String? dateUsage;
  final String suket;
  final int approve;
  final String? approvedBy;
  final String? approveDate;
  final int idTanah;
  final int idSupplierAsalKayu;

  KayuBulatModel({
    required this.noKayuBulat,
    required this.noPlat,
    required this.idJenisKayu,
    required this.idSupplier,
    required this.idPengukuran,
    required this.noTruk,
    required this.jenisTruk,
    required this.dateCreate,
    required this.pengurangan,
    this.dateUsage,
    required this.suket,
    required this.approve,
    this.approvedBy,
    this.approveDate,
    required this.idTanah,
    required this.idSupplierAsalKayu,
  });

  factory KayuBulatModel.fromJson(Map<String, dynamic> json) {
    return KayuBulatModel(
      noKayuBulat: json['NoKayuBulat']?.toString() ?? '',
      noPlat: json['NoPlat']?.toString() ?? '',
      idJenisKayu: json['IdJenisKayu'] is int
          ? json['IdJenisKayu']
          : int.tryParse(json['IdJenisKayu'].toString()) ?? 0,
      idSupplier: json['IdSupplier'] is int
          ? json['IdSupplier']
          : int.tryParse(json['IdSupplier'].toString()) ?? 0,
      idPengukuran: json['IdPengukuran'] is int
          ? json['IdPengukuran']
          : int.tryParse(json['IdPengukuran'].toString()) ?? 0,
      noTruk: json['NoTruk']?.toString() ?? '',
      jenisTruk: json['JenisTruk']?.toString() ?? '',
      dateCreate: json['DateCreate']?.toString() ?? '',
      pengurangan: json['Pengurangan'] is int
          ? json['Pengurangan']
          : int.tryParse(json['Pengurangan'].toString()) ?? 0,
      dateUsage: json['DateUsage']?.toString(),
      suket: json['Suket']?.toString() ?? '',
      approve: json['Approve'] is int
          ? json['Approve']
          : int.tryParse(json['Approve'].toString()) ?? 0,
      approvedBy: json['ApprovedBy']?.toString(),
      approveDate: json['ApproveDate']?.toString(),
      idTanah: json['IdTanah'] is int
          ? json['IdTanah']
          : int.tryParse(json['IdTanah'].toString()) ?? 0,
      idSupplierAsalKayu: json['IdSupplierAsalKayu'] is int
          ? json['IdSupplierAsalKayu']
          : int.tryParse(json['IdSupplierAsalKayu'].toString()) ?? 0,
    );
  }
}
