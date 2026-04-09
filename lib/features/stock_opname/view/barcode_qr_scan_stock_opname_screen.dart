import 'dart:async'; // Import Timer
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../view_model/stock_opname_detail_view_model.dart';
import '../widget/not_found_dialog.dart'; // Import widget NotFoundDialog
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

class BarcodeQrScanScreen extends StatefulWidget {
  final String noSO;
  final String selectedFilter;
  final String idLokasi;

  const BarcodeQrScanScreen(
      {super.key,
      required this.noSO,
      required this.selectedFilter,
      required this.idLokasi});

  @override
  State<BarcodeQrScanScreen> createState() => _BarcodeQrScanScreenState();
}

class _BarcodeQrScanScreenState extends State<BarcodeQrScanScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController cameraController = MobileScannerController();
  bool isFlashOn = false;
  bool hasCameraPermission = false;
  late AnimationController _animationController;
  bool _isDetected = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ImagePicker _imagePicker = ImagePicker();
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  bool _isSaving = false; // State untuk loading
  bool _isOcrProcessing = false;
  String _saveMessage = ''; // State untuk pesan

  Timer? _debounceTimer; // Timer untuk debouncing
  String? _lastScannedCode; // Kode yang terakhir diproses
  static final RegExp _validLabelPattern =
      RegExp(r'^[A-Z0-9][A-Z0-9\/\.\-_]{5,24}$');
  static const List<String> _labelKeywords = [
    'NO LABEL',
    'NO. LABEL',
    'NOMOR LABEL',
    'NOLABEL',
    'LABEL NO',
    'LABEL',
  ];

  @override
  void initState() {
    super.initState();
    _getCameraPermission();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _getCameraPermission() async {
    final status = await Permission.camera.request();
    if (!mounted) return;

    setState(() {
      hasCameraPermission = status == PermissionStatus.granted;
    });

    if (status == PermissionStatus.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Izin kamera ditolak. Buka pengaturan aplikasi untuk memberikan izin.'),
          action: SnackBarAction(
            label: 'Buka Pengaturan',
            onPressed: () {
              openAppSettings();
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    _animationController.dispose();
    _debounceTimer?.cancel(); // Batalkan timer jika ada
    _audioPlayer.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  void _processScanResult(String rawValue) async {
    final normalizedValue = rawValue.trim().toUpperCase();
    if (normalizedValue.isEmpty) {
      return;
    }

    if (normalizedValue != _lastScannedCode) {
      setState(() {
        _isSaving = true;
      });
      // Hanya proses jika kode berbeda
      _lastScannedCode = normalizedValue; // Update kode terakhir
      final viewModel =
          Provider.of<StockOpnameInputViewModel>(context, listen: false);
      viewModel.processScannedCode(
        normalizedValue,
        widget.idLokasi,
        widget.noSO,
        onSaveComplete: (success, statusCode, message) {
          if (statusCode == 404 || statusCode == 409) {
            // Menangani statusCode 404 atau 409 dengan dialog konfirmasi
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return NotFoundDialog(
                  message: message, // Pesan error dari API
                  onConfirm: () {
                    // Lanjutkan pemrosesan jika user pilih "Ya"
                    viewModel.processScannedCode(
                      normalizedValue,
                      widget.idLokasi,
                      widget.noSO,
                      onSaveComplete: (success, statusCode, message) {
                        setState(() {
                          _isSaving = false;
                          _saveMessage =
                              '$message\nLabel : $normalizedValue'; // Gabungkan pesan dan hasil scan
                        });

                        if (success) {
                          final viewModel =
                              Provider.of<StockOpnameInputViewModel>(context,
                                  listen: false);
                          viewModel.fetchData(widget.noSO,
                              filterBy: widget.selectedFilter,
                              idLokasi: widget.idLokasi);

                          // Hapus pesan setelah beberapa detik
                          Future.delayed(const Duration(seconds: 3), () {
                            setState(() {
                              _saveMessage = '';
                            });
                            _lastScannedCode =
                                null; // Reset setelah pesan hilang
                          });
                        } else {
                          // Hapus pesan setelah beberapa detik
                          Future.delayed(const Duration(seconds: 3), () {
                            setState(() {
                              _saveMessage = '';
                            });
                            _lastScannedCode =
                                null; // Reset setelah pesan hilang
                          });
                        }
                      },
                      forceSave:
                          true, // Flag untuk memaksa penyimpanan meskipun data tidak ada
                    );
                  },
                );
              },
            );
          } else {
            debugPrint("Masuk ke kondisi else, memulai getaran");

            if (statusCode == 201 || statusCode == 200) {
              // Memutar suara accepted.mp3 dengan kecepatan 2x
              _audioPlayer.setPlaybackRate(2.0); // Kecepatan 2x
              _audioPlayer.play(AssetSource('sounds/accepted.mp3'));
            } else {
              // Memutar suara denied.mp3 dengan kecepatan 2x
              _audioPlayer.setPlaybackRate(2.0); // Kecepatan 2x
              _audioPlayer.play(AssetSource('sounds/denied.mp3'));
              Vibration.vibrate(duration: 1000);
            }

            final viewModel =
                Provider.of<StockOpnameInputViewModel>(context, listen: false);
            viewModel.fetchData(widget.noSO,
                filterBy: widget.selectedFilter, idLokasi: widget.idLokasi);

            setState(() {
              _isSaving = false;
              _saveMessage =
                  '$message\nLabel : $normalizedValue'; // Gabungkan pesan dan hasil scan
            });

            // Hapus pesan setelah beberapa detik
            Future.delayed(const Duration(seconds: 3), () {
              setState(() {
                _saveMessage = '';
              });
              _lastScannedCode = null; // Reset setelah pesan hilang
            });
          }
        },
      );
    } else {
      debugPrint('Duplicate scan detected, skipping.');
    }
  }

  Future<void> _handleOcrFallback() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Ambil Foto Label'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (image == null) return;

      setState(() {
        _isOcrProcessing = true;
      });

      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      final rawText = recognizedText.text;

      if (!mounted) return;

      if (rawText.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Teks label tidak terbaca. Coba ulangi dengan foto lebih jelas.'),
          ),
        );
        return;
      }

      final candidates = _extractLabelCandidates(recognizedText);
      final selectedLabel =
          await _showOcrReviewDialog(rawText: rawText, candidates: candidates);
      if (!mounted || selectedLabel == null) return;

      _processScanResult(selectedLabel);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OCR gagal diproses: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOcrProcessing = false;
        });
      }
    }
  }

  List<String> _extractLabelCandidates(RecognizedText recognizedText) {
    final scored = <String, int>{};
    final allLines = <String>[];

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final lineText = line.text.trim();
        if (lineText.isNotEmpty) {
          allLines.add(lineText);
        }
      }
    }

    if (allLines.isEmpty && recognizedText.text.trim().isNotEmpty) {
      allLines.addAll(recognizedText.text.split('\n'));
    }

    for (var i = 0; i < allLines.length; i++) {
      final currentLine = allLines[i];
      final upperLine = currentLine.toUpperCase();
      final hasKeyword = _labelKeywords.any(upperLine.contains);

      if (hasKeyword) {
        final direct = _extractAfterKeyword(upperLine);
        if (direct != null) {
          _addCandidate(scored, direct, 130);
        }

        for (final token in _extractTokens(upperLine)) {
          _addCandidate(scored, token, 95);
        }

        if (i + 1 < allLines.length) {
          for (final token in _extractTokens(allLines[i + 1].toUpperCase())) {
            _addCandidate(scored, token, 85);
          }
        }
        if (i + 2 < allLines.length) {
          for (final token in _extractTokens(allLines[i + 2].toUpperCase())) {
            _addCandidate(scored, token, 55);
          }
        }
      } else {
        for (final token in _extractTokens(upperLine)) {
          _addCandidate(scored, token, 25);
        }
      }
    }

    final sorted = scored.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((entry) => entry.key).take(8).toList();
  }

  String? _extractAfterKeyword(String upperLine) {
    final match = RegExp(
      r'(?:NO[\s\.\-_]*LABEL|NOLABEL|NOMOR[\s\.\-_]*LABEL|LABEL(?:\s*NO)?)\s*[:\-]?\s*([A-Z0-9\/\.\-_\s]{4,})',
    ).firstMatch(upperLine);
    if (match == null) return null;
    final raw = match.group(1);
    if (raw == null) return null;
    for (final token in _extractTokens(raw)) {
      return token;
    }
    return null;
  }

  List<String> _extractTokens(String text) {
    final tokens = <String>[];
    final matches = RegExp(r'[A-Z0-9][A-Z0-9\/\.\-_\s]{4,30}').allMatches(text);
    for (final match in matches) {
      final raw = match.group(0);
      if (raw == null) continue;
      final cleaned = _sanitizeCandidate(raw);
      if (cleaned != null) {
        tokens.add(cleaned);
      }
      final normalizedVariants = _generateAmbiguousVariants(raw);
      for (final variant in normalizedVariants) {
        final normalized = _sanitizeCandidate(variant);
        if (normalized != null) {
          tokens.add(normalized);
        }
      }
    }
    return tokens;
  }

  void _addCandidate(Map<String, int> scored, String rawToken, int baseScore) {
    final token = _sanitizeCandidate(rawToken);
    if (token == null) return;

    var score = baseScore;
    if (token.contains('-') || token.contains('/')) score += 10;
    if (_containsLettersAndDigits(token)) score += 20;
    if (token.length >= 8 && token.length <= 18) score += 10;
    if (_looksLikeNoise(token)) score -= 60;

    final prev = scored[token];
    if (prev == null || score > prev) {
      scored[token] = score;
    }
  }

  String? _sanitizeCandidate(String raw) {
    var value = raw.toUpperCase().trim();
    value = value.replaceAll(RegExp(r'[\s:;,\(\)\[\]\{\}]'), '');
    value = value.replaceAll(RegExp(r'^[\.\-_\/]+|[\.\-_\/]+$'), '');
    if (value.length < 6 || value.length > 25) return null;
    if (!_validLabelPattern.hasMatch(value)) return null;
    if (!_containsMinimumDigits(value)) return null;
    if (_looksLikeNoise(value)) return null;
    return value;
  }

  bool _containsLettersAndDigits(String text) {
    return RegExp(r'[A-Z]').hasMatch(text) && RegExp(r'\d').hasMatch(text);
  }

  bool _containsMinimumDigits(String text) {
    final digits = RegExp(r'\d').allMatches(text).length;
    return digits >= 2;
  }

  List<String> _generateAmbiguousVariants(String raw) {
    final upper = raw.toUpperCase();
    final variants = <String>{};
    variants.add(upper.replaceAll('O', '0'));
    variants.add(upper.replaceAll('I', '1'));
    variants.add(upper.replaceAll('S', '5'));
    variants.add(upper.replaceAll('B', '8'));
    variants.add(
      upper
          .replaceAll('O', '0')
          .replaceAll('I', '1')
          .replaceAll('S', '5')
          .replaceAll('B', '8'),
    );
    variants.remove(upper);
    return variants.toList();
  }

  bool _looksLikeNoise(String token) {
    const ignorePrefixes = [
      'JENIS',
      'UKURAN',
      'QTY',
      'TOTAL',
      'LABEL',
      'NO',
      'JENISLABEL',
      'NOMORLABEL',
      'STOCKOPNAME',
    ];
    return ignorePrefixes.any((prefix) => token.startsWith(prefix));
  }

  Future<String?> _showOcrReviewDialog({
    required String rawText,
    required List<String> candidates,
  }) async {
    final initial = candidates.isNotEmpty ? candidates.first : '';
    final controller = TextEditingController(text: initial);
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hasil OCR Label'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'No Label',
                    hintText: 'Masukkan no label hasil OCR',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                if (candidates.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: candidates
                          .map(
                            (item) => ActionChip(
                              label: Text(item),
                              onPressed: () {
                                controller.text = item;
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    rawText,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                final value = controller.text.trim().toUpperCase();
                if (value.isEmpty) return;
                Navigator.of(context).pop(value);
              },
              child: const Text('Gunakan'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return selected;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final scanAreaSize = screenWidth * 0.6;
    final count = Provider.of<StockOpnameInputViewModel>(context).totalData;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Lokasi ${widget.idLokasi} | $count Label',
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white, // Set background color to white
        elevation: 0,
        iconTheme:
            const IconThemeData(color: Colors.black), // Set icon color to black
        actions: [
          IconButton(
            icon: Icon(
              isFlashOn ? Icons.flash_off : Icons.flash_on,
              color: Colors.black, // Set the icon color to black
            ),
            onPressed: () async {
              setState(() {
                isFlashOn = !isFlashOn;
              });

              // Toggle torch (flashlight)
              cameraController.toggleTorch();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (hasCameraPermission)
            MobileScanner(
              controller: cameraController,
              scanWindow: Rect.fromCenter(
                center: Offset(screenWidth / 2, screenHeight / 2),
                width: scanAreaSize,
                height: scanAreaSize,
              ),
              onDetect: (capture) {
                try {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final String? rawValue = barcodes
                        .first.rawValue; // Simpan rawValue di variabel lokal
                    if (rawValue != null && !_isDetected) {
                      // Pastikan rawValue tidak null
                      setState(() {
                        _isDetected = true;
                      });
                      _animationController.forward(from: 0);

                      if (_debounceTimer?.isActive ?? false) {
                        _debounceTimer?.cancel();
                      }
                      _debounceTimer =
                          Timer(const Duration(milliseconds: 500), () {
                        setState(() {
                          _isDetected = false;
                        });
                        _processScanResult(
                            rawValue); // Panggil fungsi pemrosesan
                      });
                    }
                  } else {
                    setState(() {
                      _isDetected = false;
                    });
                  }
                } catch (e) {
                  debugPrint('Error during barcode detection: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Terjadi kesalahan saat memproses barcode.')),
                  );
                }
              },
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Izin kamera diperlukan untuk memindai.'),
                  ElevatedButton(
                    onPressed: () {
                      _getCameraPermission();
                    },
                    child: const Text('Minta Izin Kamera'),
                  ),
                ],
              ),
            ),

          // Tampilan Status
          Positioned(
            bottom: 50, // Atur jarak dari bawah
            left: 0,
            right: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isSaving
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : _saveMessage.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20), // Tambahkan margin horizontal
                          decoration: BoxDecoration(
                            color: _saveMessage.startsWith('Data berhasil')
                                ? Colors.green
                                : Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _saveMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      : const SizedBox.shrink(),
            ),
          ),

          Positioned(
            bottom: 110,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed:
                  (_isSaving || _isOcrProcessing) ? null : _handleOcrFallback,
              icon: _isOcrProcessing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.text_snippet_outlined),
              label: Text(_isOcrProcessing
                  ? 'Memproses OCR...'
                  : 'QR gagal? Coba OCR Label'),
            ),
          ),

          // Ikon Status (check.png atau cross.png)
          if (_saveMessage.isNotEmpty) // Hanya tampilkan ikon jika ada pesan
            Positioned(
              top: 150, // Atur jarak dari bawah (sesuaikan dengan kebutuhan)
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _saveMessage.startsWith('Data berhasil')
                      ? Image.asset(
                          'assets/images/check.png', // Path ke check.png
                          key: const ValueKey('check'),
                          width: 120, // Sesuaikan ukuran ikon
                          height: 120,
                        )
                      : Image.asset(
                          'assets/images/cross.png', // Path ke cross.png
                          key: const ValueKey('cross'),
                          width: 80, // Sesuaikan ukuran ikon
                          height: 80,
                        ),
                ),
              ),
            ),

          // Box Decoration (tidak diubah)
          Align(
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: scanAreaSize,
              height: scanAreaSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isDetected
                      ? Colors.greenAccent.withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.2),
                  width: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
