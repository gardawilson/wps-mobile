class KayuBulatAttachmentModel {
  final String id;
  final String url;
  final String type; // "image" atau "video"

  KayuBulatAttachmentModel({
    required this.id,
    required this.url,
    required this.type,
  });

  factory KayuBulatAttachmentModel.fromJson(Map<String, dynamic> json) {
    return KayuBulatAttachmentModel(
      id: json['Id']?.toString() ?? '',
      url: json['Url'] ?? '',
      type: json['Type'] ?? 'image',
    );
  }
}
