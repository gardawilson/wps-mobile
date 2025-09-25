import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../../model/video_tier_model.dart';
import '../../view_model/kayu_bulat_attachment_view_model.dart';
import 'video_thumbnail.dart';
import 'fullscreen_video.dart';

class VideoTierCard extends StatelessWidget {
  final int index;
  final VideoTier tier;
  final VoidCallback onPick;
  final VoidCallback onClear;
  final ValueChanged<String> onNoteChanged;
  final String noKayuBulat;

  const VideoTierCard({
    super.key,
    required this.index,
    required this.tier,
    required this.onPick,
    required this.onClear,
    required this.onNoteChanged,
    required this.noKayuBulat,
  });

  bool get _hasLocal => tier.file != null;
  bool get _hasServer => (tier.videoUrl ?? '').isNotEmpty;

  String? get _resolvedUrl {
    if (!_hasServer) return null;
    final raw = tier.videoUrl!.trim();
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    return 'http://$raw';
  }

  @override
  Widget build(BuildContext context) {
    final url = _resolvedUrl;

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
            /// Header
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
                    "Video ${tier.noUrut ?? (index + 1)}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B5A3C),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (_hasLocal)
                  _chip('Lokal')
                else if (_hasServer)
                  _chip('Server'),
                const Spacer(),

                // ✏️ Edit remark (server)
                if (_hasServer)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: "Ganti Video",
                    onPressed: onPick, // 🔥 langsung panggil onPick (camera/gallery)
                  ),

                // ❌ Delete video (server)
                if (_hasServer)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: "Hapus Video",
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Konfirmasi"),
                          content: const Text("Yakin ingin menghapus video ini?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("Batal"),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text("Hapus"),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        final vm =
                        Provider.of<KayuBulatAttachmentViewModel>(context,
                            listen: false);
                        await vm.deleteVideo(
                          noKayuBulat: noKayuBulat,
                          noUrut: tier.noUrut!,
                        );
                        await vm.fetchAttachments(noKayuBulat);
                      }
                    },
                  ),

                // ❌ Delete lokal
                if (_hasLocal)
                  IconButton(
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded, color: Colors.red),
                    tooltip: 'Hapus pilihan lokal',
                  ),
              ],
            ),

            const SizedBox(height: 16),

            /// Preview
            GestureDetector(
              onTap: () {
                if (_hasLocal) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenVideo.file(file: tier.file!),
                    ),
                  );
                } else if (_hasServer && url != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenVideo.network(url: url),
                    ),
                  );
                } else {
                  onPick();
                }
              },
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: _buildPreview(),
              ),
            ),

            const SizedBox(height: 16),

            /// Remark (tetap tampil TextField di bawah video)
            TextFormField(
              initialValue: tier.note ?? '',
              decoration: InputDecoration(
                labelText: "Keterangan Video",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
              onChanged: onNoteChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (_hasLocal) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: VideoThumbnail(file: tier.file!), // thumbnail lokal
          ),
          const Center(
            child:
            Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
          ),
        ],
      );
    }

    if (_hasServer) {
      if ((tier.thumbnailUrl ?? '').isNotEmpty) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.network(
                tier.thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image,
                      size: 40, color: Colors.grey),
                ),
              ),
            ),
            const Center(
              child: Icon(Icons.play_circle_fill,
                  color: Colors.white, size: 56),
            ),
          ],
        );
      } else {
        return const Center(
          child: Icon(Icons.play_circle_fill,
              color: Colors.white, size: 56),
        );
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.video_call_rounded,
            size: 48, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text("Tap untuk menambah video",
            style: TextStyle(color: Colors.grey[600], fontSize: 14)),
      ],
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
    );
  }
}
