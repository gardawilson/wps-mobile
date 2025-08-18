import 'label_detail_model.dart';

class CombinedLabelModel {
  final String combinedLabel;
  final String? labelType;
  final String? labelLocation;
  final String? dateCreate;
  final int? idUOMTblLebar;
  final int? idUOMPanjang;
  final String? labelM3;
  final int? labelJumlah;
  final List<LabelDetailModel> details;

  CombinedLabelModel({
    required this.combinedLabel,
    this.labelType,
    this.labelLocation,
    this.dateCreate,
    this.idUOMTblLebar,
    this.idUOMPanjang,
    this.labelM3,
    this.labelJumlah,
    this.details = const [],
  });

  factory CombinedLabelModel.fromJson(Map<String, dynamic> json) {
    // Handle details list
    List<LabelDetailModel> detailsList = [];
    if (json['Details'] != null) {
      detailsList = (json['Details'] as List)
          .map((detail) => LabelDetailModel.fromJson(detail))
          .toList();
    }

    return CombinedLabelModel(
      combinedLabel: json['CombinedLabel'] as String,
      labelType: json['LabelType'] as String?,
      labelLocation: json['LabelLocation'] as String?,
      dateCreate: json['DateCreate'] as String?,
      idUOMTblLebar: json['IdUOMTblLebar'] as int?,
      idUOMPanjang: json['IdUOMPanjang'] as int?,
      labelM3: json['LabelM3'] as String?,
      labelJumlah: json['LabelJumlah'] as int?,
      details: detailsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CombinedLabel': combinedLabel,
      'LabelType': labelType,
      'LabelLocation': labelLocation,
      'DateCreate': dateCreate,
      'IdUOMTblLebar': idUOMTblLebar,
      'IdUOMPanjang': idUOMPanjang,
      'LabelM3': labelM3,
      'LabelJumlah': labelJumlah,
      'Details': details.map((detail) => detail.toJson()).toList(),
    };
  }

  // Helper methods untuk mendapatkan informasi agregat
  int get totalDetails => details.length;

  int get totalBatang => details.fold(0, (sum, detail) => sum + (detail.jmlhBatang ?? 0));

  bool get hasDetails => details.isNotEmpty;

  // Parse labelM3 sebagai double
  double? get labelM3AsDouble {
    if (labelM3 != null) {
      return double.tryParse(labelM3!);
    }
    return null;
  }

  // Helper method untuk mendapatkan dimensi unik
  List<String> get uniqueDimensions {
    Set<String> dimensions = {};
    for (var detail in details) {
      if (detail.tebal != null && detail.lebar != null && detail.panjang != null) {
        dimensions.add('${detail.tebal}x${detail.lebar}x${detail.panjang}');
      }
    }
    return dimensions.toList();
  }

  // Helper method untuk format tanggal
  DateTime? get dateCreateAsDateTime {
    if (dateCreate != null) {
      return DateTime.tryParse(dateCreate!);
    }
    return null;
  }

  // Helper method untuk mendapatkan formatted date
  String get formattedDate {
    final date = dateCreateAsDateTime;
    if (date != null) {
      return '${date.day}/${date.month}/${date.year}';
    }
    return 'N/A';
  }

  @override
  String toString() {
    return 'CombinedLabelModel(combinedLabel: $combinedLabel, labelType: $labelType, labelLocation: $labelLocation, labelM3: $labelM3, labelJumlah: $labelJumlah, details: ${details.length} items)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CombinedLabelModel &&
        other.combinedLabel == combinedLabel &&
        other.labelType == labelType &&
        other.labelLocation == labelLocation &&
        other.dateCreate == dateCreate &&
        other.idUOMTblLebar == idUOMTblLebar &&
        other.idUOMPanjang == idUOMPanjang &&
        other.labelM3 == labelM3 &&
        other.labelJumlah == labelJumlah;
  }

  @override
  int get hashCode {
    return combinedLabel.hashCode ^
    labelType.hashCode ^
    labelLocation.hashCode ^
    dateCreate.hashCode ^
    idUOMTblLebar.hashCode ^
    idUOMPanjang.hashCode ^
    labelM3.hashCode ^
    labelJumlah.hashCode;
  }
}