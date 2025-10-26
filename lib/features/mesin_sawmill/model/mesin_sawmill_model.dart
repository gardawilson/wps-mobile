class MesinSawmill {
  final String noMeja;               // key yang dipakai untuk dikirim ke header "meja"
  final String namaMeja;
  final bool isSLP;
  final bool isGroup;
  final String? type;
  final bool enable;
  final int? idGroupMesinSawmill;
  final int? idOperator1;
  final int? idOperator2;

  MesinSawmill({
    required this.noMeja,
    required this.namaMeja,
    required this.isSLP,
    required this.isGroup,
    required this.enable,
    this.type,
    this.idGroupMesinSawmill,
    this.idOperator1,
    this.idOperator2,
  });

  factory MesinSawmill.fromJson(Map<String, dynamic> j) {
    return MesinSawmill(
      noMeja: j['noMeja']?.toString() ?? '',
      namaMeja: j['namaMeja']?.toString() ?? '',
      isSLP: j['isSLP'] == true,
      isGroup: j['isGroup'] == true,
      enable: j['enable'] == true,
      type: j['type']?.toString(),
      idGroupMesinSawmill: (j['idGroupMesinSawmill'] is num) ? (j['idGroupMesinSawmill'] as num).toInt() : null,
      idOperator1: (j['idOperator1'] is num) ? (j['idOperator1'] as num).toInt() : null,
      idOperator2: (j['idOperator2'] is num) ? (j['idOperator2'] as num).toInt() : null,
    );
  }

  @override
  String toString() {
    // tampilan item di dropdown
    return namaMeja;
  }
}
