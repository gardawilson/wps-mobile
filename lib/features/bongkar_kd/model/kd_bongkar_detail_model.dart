// 2. MODEL UNTUK DETAIL ITEM
class DetailItem {
  final int noUrut;
  final double tebal;
  final double lebar;
  final double panjang;
  final int jumlahBatang;

  DetailItem({
    required this.noUrut,
    required this.tebal,
    required this.lebar,
    required this.panjang,
    required this.jumlahBatang,
  });

  factory DetailItem.fromJson(Map<String, dynamic> json) {
    return DetailItem(
      noUrut: json['NoUrut'] ?? 0,
      tebal: (json['Tebal'] ?? 0).toDouble(),
      lebar: (json['Lebar'] ?? 0).toDouble(),
      panjang: (json['Panjang'] ?? 0).toDouble(),
      jumlahBatang: json['JmlhBatang'] ?? 0,
    );
  }
}