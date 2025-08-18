class LabelDetailModel {
  final int? noUrut;
  final double? tebal;
  final double? lebar;
  final double? panjang;
  final int? jmlhBatang;

  LabelDetailModel({
    this.noUrut,
    this.tebal,
    this.lebar,
    this.panjang,
    this.jmlhBatang,
  });

  factory LabelDetailModel.fromJson(Map<String, dynamic> json) {
    return LabelDetailModel(
      noUrut: json['NoUrut'] as int?,
      tebal: json['Tebal'] != null ? (json['Tebal'] as num).toDouble() : null,
      lebar: json['Lebar'] != null ? (json['Lebar'] as num).toDouble() : null,
      panjang: json['Panjang'] != null ? (json['Panjang'] as num).toDouble() : null,
      jmlhBatang: json['JmlhBatang'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'NoUrut': noUrut,
      'Tebal': tebal,
      'Lebar': lebar,
      'Panjang': panjang,
      'JmlhBatang': jmlhBatang,
    };
  }

  // Helper method untuk mendapatkan dimensi sebagai string
  String get dimensionString {
    if (tebal != null && lebar != null && panjang != null) {
      return '${tebal}x${lebar}x${panjang}';
    }
    return 'N/A';
  }

  // Helper method untuk menghitung volume (jika diperlukan)
  double? get volume {
    if (tebal != null && lebar != null && panjang != null) {
      return tebal! * lebar! * panjang!;
    }
    return null;
  }

  @override
  String toString() {
    return 'LabelDetailModel(noUrut: $noUrut, tebal: $tebal, lebar: $lebar, panjang: $panjang, jmlhBatang: $jmlhBatang)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LabelDetailModel &&
        other.noUrut == noUrut &&
        other.tebal == tebal &&
        other.lebar == lebar &&
        other.panjang == panjang &&
        other.jmlhBatang == jmlhBatang;
  }

  @override
  int get hashCode {
    return noUrut.hashCode ^
    tebal.hashCode ^
    lebar.hashCode ^
    panjang.hashCode ^
    jmlhBatang.hashCode;
  }
}