class KDBongkarDetailBeforeModel {
  final String noProcKD;
  final String noST;
  final String dateCreate;
  final String idLokasi;

  KDBongkarDetailBeforeModel({required this.noProcKD, required this.noST, required this.dateCreate, required this.idLokasi});

  factory KDBongkarDetailBeforeModel.fromJson(Map<String, dynamic> json) {
    return KDBongkarDetailBeforeModel(
      noProcKD: json['NoProcKD'],
      noST: json['NoST'],
      dateCreate: json['DateCreate'] ?? '-',
      idLokasi: json['IdLokasi'] ?? '-',
    );
  }
}
