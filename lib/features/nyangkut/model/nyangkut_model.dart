class NyangkutModel {
  final String NoNyangkut;
  final String tgl;

  NyangkutModel({required this.NoNyangkut, required this.tgl});

  factory NyangkutModel.fromJson(Map<String, dynamic> json) {
    return NyangkutModel(
      NoNyangkut: json['NoNyangkut'],
      tgl: json['Tgl'],
    );
  }
}
