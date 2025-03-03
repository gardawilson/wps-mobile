class CombinedLabelModel {
  final String combinedLabel;
  final String? labelType;
  final String? labelLocation; // Ubah IdLokasi menjadi LabelLocation

  CombinedLabelModel({
    required this.combinedLabel,
    this.labelType,
    this.labelLocation, // Gantilah IdLokasi menjadi LabelLocation
  });

  factory CombinedLabelModel.fromJson(Map<String, dynamic> json) {
    return CombinedLabelModel(
      combinedLabel: json['CombinedLabel'] as String,
      labelType: json['LabelType'] as String?,
      labelLocation: json['LabelLocation'] as String?, // Ambil dari API, tapi gunakan nama baru
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CombinedLabel': combinedLabel,
      'LabelType': labelType,
      'LabelLocation': labelLocation, // Ubah penyimpanan JSON
    };
  }
}
