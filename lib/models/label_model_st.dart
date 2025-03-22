class LabelModelST {
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
  final String remark;
  final bool isSLP;
  final List<Detail> details;
  final Total total;
  final String username; // Tambahkan field username
  final String formatMMYY; // Tambahkan field username


  LabelModelST({
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
    required this.remark,
    required this.isSLP,
    required this.details,
    required this.total,
    required this.username, // Tambahkan parameter username
    required this.formatMMYY, // Tambahkan parameter username


  });

  // Parsing format ST
  factory LabelModelST.fromJson(Map<String, dynamic> json) {
    var detailsList = (json['details'] as List?)
        ?.map((i) => Detail.fromJson(i))
        .toList() ?? [];
    var totalJson = json['total'] ?? {};

    return LabelModelST(
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
      remark: json['header'][0]['Remark'] ?? '',
      isSLP: json['header'][0]['IsSLP'] ?? false,
      details: detailsList,
      total: Total.fromJson(totalJson),
      username: json['username'] ?? '', // Ambil username dari JSON
      formatMMYY: json['header'][0]['FormatMMYY'] ?? '',

    );
  }
}

class Detail {
  final int noUrut;
  final int tebal;
  final int lebar;
  final int panjang;
  final int jmlhBatang;
  final double rowTON;
  final double rowM3;

  Detail({
    required this.noUrut,
    required this.tebal,
    required this.lebar,
    required this.panjang,
    required this.jmlhBatang,
    required this.rowTON,
    required this.rowM3,
  });

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
      noUrut: json['NoUrut'],
      tebal: json['Tebal'],
      lebar: json['Lebar'],
      panjang: json['Panjang'],
      jmlhBatang: json['JmlhBatang'],
      rowTON: json['RowTON'].toDouble(),
      rowM3: json['RowM3'].toDouble(),
    );
  }
}

class Total {
  final int jumlah;
  final String m3;
  final String ton;

  Total({
    required this.jumlah,
    required this.m3,
    required this.ton,
  });

  factory Total.fromJson(Map<String, dynamic> json) {
    return Total(
      jumlah: json['jumlah'],
      m3: json['m3'],
      ton: json['ton'],
    );
  }
}
