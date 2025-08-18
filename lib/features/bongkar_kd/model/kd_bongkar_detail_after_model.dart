class KDBongkarDetailAfterModel {
  final String noProcKD;
  final String noST;
  final String dateCreate;
  final String idLokasi;

  KDBongkarDetailAfterModel({required this.noProcKD, required this.noST, required this.dateCreate, required this.idLokasi});

  factory KDBongkarDetailAfterModel.fromJson(Map<String, dynamic> json) {
    return KDBongkarDetailAfterModel(
      noProcKD: json['NoProcKD'],
      noST: json['NoST'],
      dateCreate: json['DateCreate'] ?? '-',
      idLokasi: json['IdLokasi'] ?? '-',
    );
  }
}
