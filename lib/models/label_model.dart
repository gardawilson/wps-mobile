class LabelModel {
  final String noSPK;
  final String namaGrade;
  final String noProduksi;
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

  LabelModel({
    required this.noSPK,
    required this.namaGrade,
    required this.noProduksi,
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
  });

  factory LabelModel.fromJson(Map<String, dynamic> json) {
    var detailsList = (json['details'] as List)
        .map((i) => Detail.fromJson(i))
        .toList();

    return LabelModel(
      noSPK: json['header'][0]['NoSPK'],
      namaGrade: json['header'][0]['NamaGrade'] ?? "",  // Menambahkan fallback ke string kosong jika null
      noProduksi: json['header'][0]['NoProduksi'],
      profile: json['header'][0]['Profile'],  // Nullable di sini
      dateCreate: json['header'][0]['DateCreate'],
      jam: json['header'][0]['Jam'],
      namaOrgTelly: json['header'][0]['NamaOrgTelly'],
      namaMesin: json['header'][0]['NamaMesin'],
      namaWarehouse: json['header'][0]['NamaWarehouse'],
      jenis: json['header'][0]['Jenis'],
      isLembur: json['header'][0]['IsLembur'],
      isReject: json['header'][0]['IsReject'],
      remark: json['header'][0]['Remark'],  // Nullable di sini
      details: detailsList,
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
