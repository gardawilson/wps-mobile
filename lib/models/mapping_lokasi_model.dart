// models/stock_opname_input_model.dart

class MappingLokasiModel {
  final String idLokasi;
  final String blok;

  MappingLokasiModel({required this.idLokasi, required this.blok});

  factory MappingLokasiModel.fromJson(Map<String, dynamic> json) {
    return MappingLokasiModel(
      idLokasi: json['IdLokasi'] as String,
      blok: json['Blok'] as String,
    );
  }
}
