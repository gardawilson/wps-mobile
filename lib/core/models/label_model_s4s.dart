class LabelModelS4S {
  final String noKayuBulat;
  final String nmSupplier;
  final String noTruk;
  final String dateCreate;
  final String jenis;
  final String noSPK;
  final String namaOrgTelly;
  final String namaStickBy;
  final String buyerNoSPK;
  final int idUOMTblLebar;
  final int idUOMPanjang;
  final String noPlat;
  final bool isSLP;
  final String namaGrade;
  final String noProduksi;
  final String noBongkarSusun;
  final String? profile;
  final String jam;
  final String namaMesin;
  final String namaWarehouse;
  final bool isLembur;
  final bool isReject;
  final String? remark;
  final String? formatMMYY;
  final List<Detail> details;
  final Total total;

  LabelModelS4S({
    required this.noKayuBulat,
    required this.nmSupplier,
    required this.noTruk,
    required this.dateCreate,
    required this.jenis,
    required this.noSPK,
    required this.namaOrgTelly,
    required this.namaStickBy,
    required this.buyerNoSPK,
    required this.idUOMTblLebar,
    required this.idUOMPanjang,
    required this.noPlat,
    required this.isSLP,
    required this.namaGrade,
    required this.noProduksi,
    required this.noBongkarSusun,
    this.profile,
    required this.jam,
    required this.namaMesin,
    required this.namaWarehouse,
    required this.isLembur,
    required this.isReject,
    this.remark,
    this.formatMMYY,
    required this.details,
    required this.total,
  });

  // Parsing format S4S
  factory LabelModelS4S.fromJson(Map<String, dynamic> json) {
    var detailsList = (json['details'] as List?)
        ?.map((i) => Detail.fromJson(i))
        .toList() ?? [];
    var totalJson = json['total'] ?? {};

    return LabelModelS4S(
      noKayuBulat: json['header'][0]['NoKayuBulat'] ?? '',
      nmSupplier: json['header'][0]['NmSupplier'] ?? '',
      noTruk: json['header'][0]['NoTruk']?.toString() ?? '',
      dateCreate: json['header'][0]['DateCreate'] ?? '',
      jenis: json['header'][0]['Jenis'] ?? '',
      noSPK: json['header'][0]['NoSPK'] ?? '',
      namaOrgTelly: json['header'][0]['NamaOrgTelly'] ?? '',
      namaStickBy: json['header'][0]['NamaStickBy'] ?? '',
      buyerNoSPK: json['header'][0]['BuyerNoSPK'] ?? '',
      idUOMTblLebar: json['header'][0]['IdUOMTblLebar'] ?? 0,
      idUOMPanjang: json['header'][0]['IdUOMPanjang'] ?? 0,
      noPlat: json['header'][0]['NoPlat'] ?? '',
      isSLP: json['header'][0]['IsSLP'] ?? false,
      namaGrade: json['header'][0]['NamaGrade'] ?? '',
      noProduksi: json['header'][0]['NoProduksi'] ?? '',
      noBongkarSusun: json['header'][0]['NoBongkarSusun'] ?? '',
      profile: json['header'][0]['Profile'],
      jam: json['header'][0]['Jam'] ?? '',
      namaMesin: json['header'][0]['NamaMesin'] ?? '',
      namaWarehouse: json['header'][0]['NamaWarehouse'] ?? '',
      isLembur: json['header'][0]['IsLembur'] ?? false,
      isReject: json['header'][0]['IsReject'] ?? false,
      remark: json['header'][0]['Remark'],
      formatMMYY: json['header'][0]['FormatMMYY'] ?? '',
      details: detailsList,
      total: Total.fromJson(totalJson),
    );
  }
}


class Detail {
  final int noUrut;
  final int tebal;
  final int lebar;
  final int panjang;
  final int jmlhBatang;

  Detail({
    required this.noUrut,
    required this.tebal,
    required this.lebar,
    required this.panjang,
    required this.jmlhBatang,
  });

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
      noUrut: json['NoUrut'],
      tebal: json['Tebal'],
      lebar: json['Lebar'],
      panjang: json['Panjang'],
      jmlhBatang: json['JmlhBatang'],
    );
  }
}

// Model untuk 'total'
class Total {
  final int jumlah;
  final String m3;

  Total({
    required this.jumlah,
    required this.m3,
  });

  factory Total.fromJson(Map<String, dynamic> json) {
    return Total(
      jumlah: json['jumlah'],
      m3: json['m3'],
    );
  }
}
