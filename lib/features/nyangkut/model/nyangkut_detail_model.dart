class NyangkutDetailModel {
  final String combinedLabel;
  final String labelType;
  final String labelLocation;
  final String dateCreate;
  final String noNyangkut;
  final String dateLancar;

  NyangkutDetailModel({
    required this.combinedLabel,
    required this.labelType,
    required this.labelLocation,
    required this.dateCreate,
    required this.noNyangkut,
    required this.dateLancar,
  });

  factory NyangkutDetailModel.fromJson(Map<String, dynamic> json) {
    return NyangkutDetailModel(
      combinedLabel: json['CombinedLabel'] ?? '',
      labelType: json['LabelType'] ?? '',
      labelLocation: json['LabelLocation'] ?? '',
      dateCreate: json['DateCreate'] ?? '',
      noNyangkut: json['NoNyangkut'] ?? '',
      dateLancar: json['DateLancar'] ?? '',
    );
  }
}
