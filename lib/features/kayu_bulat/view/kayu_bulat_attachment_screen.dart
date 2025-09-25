import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../model/image_tier_model.dart';
import '../model/video_tier_model.dart';
import '../view_model/kayu_bulat_attachment_view_model.dart';
import 'widgets/add_button.dart';
import 'widgets/image_tier_card.dart';
import 'widgets/video_tier_card.dart';
import 'package:provider/provider.dart';

class KayuBulatAttachmentScreen extends StatefulWidget {
  final String noKayuBulat;

  const KayuBulatAttachmentScreen({super.key, required this.noKayuBulat});

  @override
  State<KayuBulatAttachmentScreen> createState() =>
      _KayuBulatAttachmentScreenState();
}

class _KayuBulatAttachmentScreenState extends State<KayuBulatAttachmentScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late TabController _tabController;

  List<ImageTier> imageTiers = [];
  List<VideoTier> videoTiers = [];

  bool get _hasTierSisipan => imageTiers.any((t) => t.tier == 0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = Provider.of<KayuBulatAttachmentViewModel>(context, listen: false);
      await vm.fetchAttachments(widget.noKayuBulat);
      setState(() {
        imageTiers = vm.imageTiers;
        videoTiers = vm.videoTiers;
      });
    });
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickImageByListIndex(int listIndex) async {
    final source = await _showMediaSourceDialog();
    if (source == null) return;

    if (source == "camera") {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => imageTiers[listIndex].file = File(picked.path));
      }
    } else {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.path != null) {
        setState(() => imageTiers[listIndex].file = File(result.files.single.path!));
      }
    }
  }

  Future<void> _pickVideo(int index) async {
    final source = await _showMediaSourceDialog(isVideo: true);
    if (source == null) return;

    File? videoFile;
    if (source == "camera") {
      final picked = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );
      if (picked != null) videoFile = File(picked.path);
    } else {
      final result = await FilePicker.platform.pickFiles(type: FileType.video);
      if (result != null && result.files.single.path != null) {
        videoFile = File(result.files.single.path!);
      }
    }

    if (videoFile != null) {
      setState(() => videoTiers[index].file = videoFile);
    }
  }

  Future<String?> _showMediaSourceDialog({bool isVideo = false}) async {
    return await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                isVideo ? "Pilih Sumber Video" : "Pilih Sumber Gambar",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 20),
              _buildSourceOption(
                icon: isVideo ? Icons.videocam_rounded : Icons.camera_alt_rounded,
                title: "Kamera",
                subtitle: isVideo ? "Rekam video baru" : "Ambil foto baru",
                onTap: () => Navigator.pop(context, "camera"),
              ),
              _buildSourceOption(
                icon: isVideo ? Icons.video_library_rounded : Icons.photo_library_rounded,
                title: "Galeri",
                subtitle: isVideo ? "Pilih dari galeri video" : "Pilih dari galeri foto",
                onTap: () => Navigator.pop(context, "gallery"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5A3C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF8B5A3C), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attachment ${widget.noKayuBulat}"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.image), text: "Gambar"),
            Tab(icon: Icon(Icons.video_library), text: "Video"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildImageTab(), _buildVideoTab()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveData,
        icon: const Icon(Icons.save),
        label: const Text("Simpan"),
      ),
    );
  }

  /// ================== IMAGE TAB ==================
  Widget _buildImageTab() {
    // Pisahkan sisipan & normal (urutkan normal mengikuti urutan di list)
    final sisipan = imageTiers.where((t) => t.tier == 0).toList();
    final normal = imageTiers.where((t) => t.tier != 0).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // 🔹 Tombol khusus (muncul hanya jika belum ada sisipan)
        if (!_hasTierSisipan)
          AddButton(
            onPressed: () {
              setState(() {
                imageTiers.insert(0, ImageTier(tier: 0));
              });
            },
            label: "Tambah Gambar (Tier Sisipan)",
            icon: Icons.add_photo_alternate,
          )
        else
          // 🔹 Sudah ada → tampilkan kartu sisipan paling atas
          Builder(builder: (_) {
            final t = sisipan.first;
            final listIndex = imageTiers.indexOf(t);
            return ImageTierCard(
              index: 0,
              tier: t,
              onPick: () => _pickImageByListIndex(listIndex),

              // ❌ hapus field (hapus element dari list)
              onRemoveField: () {
                setState(() {
                  imageTiers.removeAt(listIndex);
                });
              },

              onPcsChanged: (v) => t.pcs = int.tryParse(v) ?? 0,
              onNoteChanged: (v) => t.note = v,
              titleOverride: "Tier Sisipan",

              // sisipan selalu bisa dihapus, jadi isLast false aja
              isLast: false,
              noKayuBulat: widget.noKayuBulat,
            );
          }),


        const SizedBox(height: 12),

        // 🔹 Daftar tier normal
        ...normal.asMap().entries.map((entry) {
          final visualIdx = entry.key;
          final t = entry.value;
          final listIndex = imageTiers.indexOf(t);

          return ImageTierCard(
            index: visualIdx,
            tier: t,
            onPick: () => _pickImageByListIndex(listIndex),

            // ❌ hapus field (hapus element dari list)
            onRemoveField: () {
              setState(() {
                imageTiers.removeAt(listIndex);
              });
            },

            onPcsChanged: (v) => t.pcs = int.tryParse(v) ?? 0,
            onNoteChanged: (v) => t.note = v,

            // ✅ hanya true kalau ini tier terakhir
            isLast: listIndex == imageTiers.length - 1,
            noKayuBulat: widget.noKayuBulat,
          );
        }),

        // 🔹 Tambah tier normal
        AddButton(
          onPressed: () {
            if (imageTiers.isNotEmpty) {
              final last = imageTiers.last;

              final hasImage = last.file != null || (last.serverImageUrl?.isNotEmpty ?? false);
              final hasPcs = last.pcs > 0;

              if (!hasImage || !hasPcs) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Lengkapi gambar & jumlah PCS pada tier sebelumnya dulu."),
                  ),
                );
                return;
              }
            }

            setState(() {
              imageTiers.add(ImageTier(tier: null)); // tambah tier baru
            });
          },
          label: "Tambah Gambar",
          icon: Icons.add_photo_alternate,
        ),

      ],
    );
  }

  /// ================== VIDEO TAB (tanpa perubahan konsep tier sisipan) ==================
  Widget _buildVideoTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ...videoTiers.asMap().entries.map((entry) {
          final i = entry.key;
          final t = entry.value;
          return VideoTierCard(
            index: i,
            tier: t,
            onPick: () => _pickVideo(i),
            onClear: () {
              setState(() {
                videoTiers.removeAt(i); // 🔥 hapus tier video
              });
            },
            onNoteChanged: (v) => t.note = v,
            noKayuBulat: widget.noKayuBulat,
          );
        }),
        AddButton(
          onPressed: () => setState(() => videoTiers.add(VideoTier())),
          label: "Tambah Video",
          icon: Icons.video_call,
        ),
      ],
    );
  }

  /// ================== SAVE ==================
  void _saveData() async {
    final vm = Provider.of<KayuBulatAttachmentViewModel>(context, listen: false);

    // --- GAMBAR ---
    int running = 0;
    for (final t in imageTiers) {
      int tierValue;

      if (t.tier == 0) {
        // sisipan tetap 0
        tierValue = 0;
      } else {
        // normal tier → increment sesuai urutan
        running += 1;
        tierValue = running;
      }

      if (t.file != null) {
        await vm.uploadImage(
          noKayuBulat: widget.noKayuBulat,
          file: t.file!,
          tier: tierValue,
          pcs: t.pcs,
        );
      } else {
        await vm.updateImageMeta(
          noKayuBulat: widget.noKayuBulat,
          tier: tierValue,
          pcs: t.pcs,
          note: t.note,
        );
      }

      if (vm.errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${vm.errorMessage}")),
        );
        return;
      }
    }


    // --- VIDEO ---
    int existingMax = 0;
    if (videoTiers.isNotEmpty) {
      final existing = videoTiers.where((t) => t.noUrut != null);
      if (existing.isNotEmpty) {
        existingMax = existing.map((t) => t.noUrut!).reduce((a, b) => a > b ? a : b);
      }
    }

    int v = existingMax;
    for (final t in videoTiers) {
      if (t.file != null) {
        final noUrut = t.noUrut ?? (++v); // ✅ kalau sudah ada → pakai itu, kalau baru → increment
        await vm.uploadVideo(
          noKayuBulat: widget.noKayuBulat,
          file: t.file!,
          noUrut: noUrut,
          remark: t.note,
        );
      } else if (t.noUrut != null) {
        // Tidak ada file tapi sudah punya noUrut → update remark saja
        await vm.updateVideoMeta(
          noKayuBulat: widget.noKayuBulat,
          noUrut: t.noUrut!,
          remark: t.note,
        );
      }

      if (vm.errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error video: ${vm.errorMessage}")),
        );
        return;
      }
    }



    // ✅ Reload data dari server setelah semua selesai
    await vm.fetchAttachments(widget.noKayuBulat);

    setState(() {
      imageTiers = vm.imageTiers;
      videoTiers = vm.videoTiers;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Semua gambar & video berhasil disimpan")),
    );
  }


}
