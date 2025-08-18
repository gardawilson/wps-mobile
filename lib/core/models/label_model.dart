class LabelModel {
  final String noSPK;
  final String namaGrade;
  final String noProduksi;
  final String noBongkarSusun;
  final String? profile;  // Menjadikan nullable untuk menerima null
  final String dateCreate;
  final String jam;
  final String namaOrgTelly;
  final String namaMesin;
  final String namaWarehouse;
  final String jenis;
  final bool isLembur;
  final bool isReject;
  final String? remark;
  final List<Detail> details;
  final Total total; // Properti untuk menampung total
  final String? formatMMYY; // Menambahkan properti formatMMYY


  LabelModel({
    required this.noSPK,
    required this.namaGrade,
    required this.noProduksi,
    required this.noBongkarSusun,
    this.profile,  // nullable
    required this.dateCreate,
    required this.jam,
    required this.namaOrgTelly,
    required this.namaMesin,
    required this.namaWarehouse,
    required this.jenis,
    required this.isLembur,
    required this.isReject,
    this.remark,
    required this.details,
    required this.total,  // Menambahkan parameter total
    this.formatMMYY,  // Menambahkan parameter formatMMYY

  });

  factory LabelModel.fromJson(Map<String, dynamic> json) {
    var detailsList = (json['details'] as List)
        .map((i) => Detail.fromJson(i))
        .toList();

    // Parsing total
    var totalJson = json['total'];

    return LabelModel(
      noSPK: json['header'][0]['NoSPK'] ?? '',  // Menambahkan fallback untuk null
      namaGrade: json['header'][0]['NamaGrade'] ?? "",  // Menambahkan fallback untuk null
      noProduksi: json['header'][0]['NoProduksi'] ?? '',  // Menambahkan fallback untuk null
      noBongkarSusun: json['header'][0]['NoBongkarSusun'] ?? '',  // Menambahkan fallback untuk null
      profile: json['header'][0]['Profile'],  // Nullable di sini
      dateCreate: json['header'][0]['DateCreate'] ?? '',  // Menambahkan fallback untuk null
      jam: json['header'][0]['Jam'] ?? '',  // Menambahkan fallback untuk null
      namaOrgTelly: json['header'][0]['NamaOrgTelly'] ?? '',  // Menambahkan fallback untuk null
      namaMesin: json['header'][0]['NamaMesin'] ?? '',  // Menambahkan fallback untuk null
      namaWarehouse: json['header'][0]['NamaWarehouse'] ?? '',  // Menambahkan fallback untuk null
      jenis: json['header'][0]['Jenis'] ?? '',  // Menambahkan fallback untuk null
      isLembur: json['header'][0]['IsLembur'] ?? false,  // Menambahkan fallback untuk null
      isReject: json['header'][0]['IsReject'] ?? false,  // Menambahkan fallback untuk null
      remark: json['header'][0]['Remark'],  // Nullable di sini
      details: detailsList,
      total: Total.fromJson(totalJson),  // Parsing total
      formatMMYY: json['header'][0]['FormatMMYY'] ?? '',  // Menambahkan fallback untuk null

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
