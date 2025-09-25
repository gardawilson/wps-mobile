import 'dart:io';

class VideoTier {
  // urutan di server
  int? noUrut;
  String? note;       // di server: remark
  File? file;         // lokal

  // dari server
  String? videoName;
  String? videoUrl;
  String? thumbnailUrl; // 🔹 baru

  VideoTier({
    this.noUrut,
    this.note,
    this.file,
    this.videoName,
    this.videoUrl,
    this.thumbnailUrl,
  });

  factory VideoTier.fromJson(Map<String, dynamic> json) {
    return VideoTier(
      noUrut: (json['noUrut'] as num?)?.toInt(),
      note: json['remark'] as String?,
      videoName: json['videoName'] as String?,
      videoUrl: json['videoUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?, // 🔹
    );
  }

  Map<String, dynamic> toJson() => {
    'noUrut': noUrut,
    'remark': note,
    'videoName': videoName,
    'videoUrl': videoUrl,
    'thumbnailUrl': thumbnailUrl, // 🔹
  };
}
