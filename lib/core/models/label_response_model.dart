import 'combined_label_model.dart';

class LabelResponseModel {
  final List<CombinedLabelModel> noLabelList;
  final bool noLabelFound;
  final int currentPage;
  final int pageSize;
  final int totalData;
  final int totalPages;
  final LabelSummary summary;

  LabelResponseModel({
    required this.noLabelList,
    required this.noLabelFound,
    required this.currentPage,
    required this.pageSize,
    required this.totalData,
    required this.totalPages,
    required this.summary,
  });

  factory LabelResponseModel.fromJson(Map<String, dynamic> json) {
    // Parse noLabelList
    List<CombinedLabelModel> labelList = [];
    if (json['noLabelList'] != null) {
      labelList = (json['noLabelList'] as List)
          .map((item) => CombinedLabelModel.fromJson(item))
          .toList();
    }

    // Parse summary
    LabelSummary summaryData = LabelSummary.fromJson(json['summary'] ?? {});

    return LabelResponseModel(
      noLabelList: labelList,
      noLabelFound: json['noLabelFound'] as bool? ?? false,
      currentPage: json['currentPage'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 0,
      totalData: json['totalData'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      summary: summaryData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'noLabelList': noLabelList.map((item) => item.toJson()).toList(),
      'noLabelFound': noLabelFound,
      'currentPage': currentPage,
      'pageSize': pageSize,
      'totalData': totalData,
      'totalPages': totalPages,
      'summary': summary.toJson(),
    };
  }

  // Helper methods untuk pagination
  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;
  int get nextPage => hasNextPage ? currentPage + 1 : currentPage;
  int get previousPage => hasPreviousPage ? currentPage - 1 : currentPage;

  // Helper method untuk mendapatkan range data saat ini
  String get currentDataRange {
    int start = ((currentPage - 1) * pageSize) + 1;
    int end = currentPage * pageSize;
    if (end > totalData) end = totalData;
    return '$start-$end of $totalData';
  }

  // Helper method untuk mendapatkan persentase data yang sudah diload
  double get loadedPercentage {
    if (totalData == 0) return 0.0;
    int loadedData = currentPage * pageSize;
    if (loadedData > totalData) loadedData = totalData;
    return (loadedData / totalData) * 100;
  }

  // Helper method untuk check apakah ada data
  bool get hasData => noLabelList.isNotEmpty;

  // Helper method untuk mendapatkan total items di halaman saat ini
  int get currentPageItemCount => noLabelList.length;

  @override
  String toString() {
    return 'LabelResponseModel(noLabelList: ${noLabelList.length} items, noLabelFound: $noLabelFound, currentPage: $currentPage, totalData: $totalData, totalPages: $totalPages)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LabelResponseModel &&
        other.noLabelFound == noLabelFound &&
        other.currentPage == currentPage &&
        other.pageSize == pageSize &&
        other.totalData == totalData &&
        other.totalPages == totalPages &&
        other.summary == summary;
  }

  @override
  int get hashCode {
    return noLabelFound.hashCode ^
    currentPage.hashCode ^
    pageSize.hashCode ^
    totalData.hashCode ^
    totalPages.hashCode ^
    summary.hashCode;
  }
}

class LabelSummary {
  final String totalM3;
  final int totalJumlah;

  LabelSummary({
    required this.totalM3,
    required this.totalJumlah,
  });

  factory LabelSummary.fromJson(Map<String, dynamic> json) {
    return LabelSummary(
      totalM3: json['totalM3'] as String? ?? '0',
      totalJumlah: json['totalJumlah'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalM3': totalM3,
      'totalJumlah': totalJumlah,
    };
  }

  // Helper method untuk mendapatkan totalM3 sebagai double
  double get totalM3AsDouble {
    return double.tryParse(totalM3) ?? 0.0;
  }

  // Helper method untuk format M3 dengan separator
  String get formattedTotalM3 {
    final value = totalM3AsDouble;
    return value.toStringAsFixed(2);
  }

  // Helper method untuk format jumlah dengan separator
  String get formattedTotalJumlah {
    return totalJumlah.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]},',
    );
  }

  @override
  String toString() {
    return 'LabelSummary(totalM3: $totalM3, totalJumlah: $totalJumlah)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LabelSummary &&
        other.totalM3 == totalM3 &&
        other.totalJumlah == totalJumlah;
  }

  @override
  int get hashCode {
    return totalM3.hashCode ^ totalJumlah.hashCode;
  }
}