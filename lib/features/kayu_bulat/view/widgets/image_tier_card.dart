import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wps_mobile/features/kayu_bulat/view_model/kayu_bulat_attachment_view_model.dart';
import '../../model/image_tier_model.dart';
import '../../view_model/kayu_bulat_attachment_view_model.dart';
import 'fullscreen_image.dart';
import 'package:provider/provider.dart';


class ImageTierCard extends StatelessWidget {
  final int index; // index visual untuk tier normal (0-based)
  final ImageTier tier;
  final VoidCallback onPick;

  /// ❌ hapus field tier (hanya tier terakhir / sisipan)
  final VoidCallback onRemoveField;

  final ValueChanged<String> onNoteChanged;
  final ValueChanged<String> onPcsChanged;
  final String? titleOverride;

  /// Apakah card ini tier terakhir dalam list?
  final bool isLast;

  final noKayuBulat;

  const ImageTierCard({
    super.key,
    required this.index,
    required this.tier,
    required this.onPick,
    required this.onRemoveField,
    required this.onNoteChanged,
    required this.onPcsChanged,
    this.titleOverride,
    this.isLast = false,
    required this.noKayuBulat
  });

  @override
  Widget build(BuildContext context) {
    final isSisipan = tier.tier == 0;
    final title =
        titleOverride ?? (isSisipan ? "Tier Sisipan" : "Tier ${index + 1}");

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header Tier + tombol aksi
            Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5A3C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B5A3C),
                    ),
                  ),
                ),
                const Spacer(),

                // ✏️ Ganti gambar (muncul kalau sudah ada gambar)
                if (tier.file != null || tier.serverImageUrl != null)
                  IconButton(
                    onPressed: onPick,
                    icon: const Icon(Icons.edit_rounded,
                        color: Colors.blueAccent),
                    iconSize: 20,
                    tooltip: "Ganti Gambar",
                  ),

                // ❌ Hapus tier (selalu untuk sisipan, hanya last utk normal)
                if (isSisipan || isLast)
                  IconButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Konfirmasi"),
                          content: Text("Hapus tier ini dari server?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("Batal"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text("Hapus"),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        final vm = Provider.of<KayuBulatAttachmentViewModel>(
                          context,
                          listen: false,
                        );

                        await vm.deleteImage(
                          noKayuBulat: noKayuBulat, // pastikan model punya ini
                          tier: tier.tier ?? index + 1,
                        );

                        if (vm.errorMessage.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Gambar berhasil dihapus")),
                          );
                          onRemoveField(); // hapus juga dari list lokal
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: ${vm.errorMessage}")),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.close_rounded, color: Colors.redAccent),
                    iconSize: 20,
                    tooltip: "Hapus Tier",
                  ),

              ],
            ),
            const SizedBox(height: 16),

            /// Image Preview
            GestureDetector(
              onTap: () {
                if (tier.file != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenImage.file(tier.file!),
                    ),
                  );
                } else if (tier.serverImageUrl != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          FullScreenImage.network(tier.serverImageUrl!),
                    ),
                  );
                } else {
                  onPick();
                }
              },
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: _buildImagePreview(),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              initialValue: tier.pcs > 0 ? tier.pcs.toString() : "",
              decoration: _inputDecoration("Jumlah PCS"),
              keyboardType: TextInputType.number,
              onChanged: onPcsChanged,
            ),
            const SizedBox(height: 16),

            // TextFormField(
            //   initialValue: tier.note,
            //   decoration: _inputDecoration("Keterangan"),
            //   maxLines: 4,
            //   onChanged: onNoteChanged,
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (tier.file != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.file(tier.file!, fit: BoxFit.cover),
      );
    } else if (tier.serverImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.network(
          tier.serverImageUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                    (progress.expectedTotalBytes ?? 1)
                    : null,
              ),
            );
          },
          errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image, size: 48, color: Colors.grey),
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_rounded,
              size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text("Tap untuk menambah gambar",
              style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      );
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
