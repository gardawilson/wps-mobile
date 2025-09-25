import 'dart:io';

class ImageTier {
  File? file;               // kalau user pilih gambar dari lokal
  int pcs;
  String note;
  String? serverImageUrl;   // full url dari backend
  String? imageName;        // optional kalau butuh nama file dari DB
  int? tier;

  ImageTier({
    this.file,
    this.pcs = 0,
    this.note = "",
    this.serverImageUrl,
    this.imageName,
    this.tier,
  });

  factory ImageTier.fromJson(Map<String, dynamic> json) {
    return ImageTier(
      tier: json['tier'],
      pcs: json['pcs'] ?? 0,
      serverImageUrl: json['imageUrl'],
      imageName: json['imageName'],
    );
  }
}
