// lib/features/qc_sawmill/model/qc_sawmill_detail.dart
class QcSawmillDetail {
  final String noQc;
  final int? noUrut;
  final String? noST;
  final double? cuttingTebal;
  final double? cuttingLebar;
  final double? actualTebal;
  final double? actualLebar;
  final double? susutTebal;
  final double? susutLebar;

  QcSawmillDetail({
    required this.noQc,
    this.noUrut,
    this.noST,
    this.cuttingTebal,
    this.cuttingLebar,
    this.actualTebal,
    this.actualLebar,
    this.susutTebal,
    this.susutLebar,
  });

  // ---------- parsing helpers ----------
  static double? _toD(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static int? _toI(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  // ---------- factory from API ----------
  factory QcSawmillDetail.fromJson(Map<String, dynamic> j) {
    return QcSawmillDetail(
      noQc: j['noQc']?.toString() ?? '',
      noUrut: _toI(j['noUrut']),
      noST: j['noST']?.toString(),
      cuttingTebal: _toD(j['cuttingTebal']),
      cuttingLebar: _toD(j['cuttingLebar']),
      actualTebal: _toD(j['actualTebal']),
      actualLebar: _toD(j['actualLebar']),
      susutTebal: _toD(j['susutTebal']),
      susutLebar: _toD(j['susutLebar']),
    );
  }

  // ---------- toJson (debug/local store) ----------
  Map<String, dynamic> toJson() {
    return {
      'noQc': noQc,
      'noUrut': noUrut,
      'noST': noST,
      'cuttingTebal': cuttingTebal,
      'cuttingLebar': cuttingLebar,
      'actualTebal': actualTebal,
      'actualLebar': actualLebar,
      'susutTebal': susutTebal,
      'susutLebar': susutLebar,
    };
  }

  // ---------- copyWith ----------
  QcSawmillDetail copyWith({
    String? noQc,
    int? noUrut,
    String? noST,
    double? cuttingTebal,
    double? cuttingLebar,
    double? actualTebal,
    double? actualLebar,
    double? susutTebal,
    double? susutLebar,
  }) {
    return QcSawmillDetail(
      noQc: noQc ?? this.noQc,
      noUrut: noUrut ?? this.noUrut,
      noST: noST ?? this.noST,
      cuttingTebal: cuttingTebal ?? this.cuttingTebal,
      cuttingLebar: cuttingLebar ?? this.cuttingLebar,
      actualTebal: actualTebal ?? this.actualTebal,
      actualLebar: actualLebar ?? this.actualLebar,
      susutTebal: susutTebal ?? this.susutTebal,
      susutLebar: susutLebar ?? this.susutLebar,
    );
  }

  // ---------- convenience (optional) ----------
  /// If `susutTebal` is null but cutting/actual available, compute (cutting - actual)
  double? get susutTebalAuto {
    if (susutTebal != null) return susutTebal;
    if (cuttingTebal != null && actualTebal != null) {
      return (cuttingTebal! - actualTebal!);
    }
    return null;
  }

  /// If `susutLebar` is null but cutting/actual available, compute (cutting - actual)
  double? get susutLebarAuto {
    if (susutLebar != null) return susutLebar;
    if (cuttingLebar != null && actualLebar != null) {
      return (cuttingLebar! - actualLebar!);
    }
    return null;
  }

  // (Optional) equality/hash if you need Set/List dedup or testing
  @override
  bool operator ==(Object other) {
    return other is QcSawmillDetail &&
        other.noQc == noQc &&
        other.noUrut == noUrut &&
        other.noST == noST &&
        other.cuttingTebal == cuttingTebal &&
        other.cuttingLebar == cuttingLebar &&
        other.actualTebal == actualTebal &&
        other.actualLebar == actualLebar &&
        other.susutTebal == susutTebal &&
        other.susutLebar == susutLebar;
  }

  @override
  int get hashCode => Object.hash(
    noQc,
    noUrut,
    noST,
    cuttingTebal,
    cuttingLebar,
    actualTebal,
    actualLebar,
    susutTebal,
    susutLebar,
  );
}
