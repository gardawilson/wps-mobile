import 'dart:async'; // Import Timer
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../view_models/stock_opname_input_view_model.dart';
import 'package:flutter/foundation.dart';

class BarcodeQrScanScreen extends StatefulWidget {
  final String blok;
  final String idLokasi;
  final String noSO;

  const BarcodeQrScanScreen({Key? key, required this.blok, required this.idLokasi, required this.noSO}) : super(key: key);

  @override
  _BarcodeQrScanScreenState createState() => _BarcodeQrScanScreenState();
}

class _BarcodeQrScanScreenState extends State<BarcodeQrScanScreen> with SingleTickerProviderStateMixin {
  final MobileScannerController cameraController = MobileScannerController();
  String? _scanResult;
  bool isFlashOn = false;
  bool hasCameraPermission = false;
  late AnimationController _animationController;
  bool _isDetected = false;

  bool _isSaving = false; // State untuk loading
  String _saveMessage = ''; // State untuk pesan

  Timer? _debounceTimer; // Timer untuk debouncing
  String? _lastScannedCode; // Kode yang terakhir diproses

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
    setState(() {
      hasCameraPermission = status == PermissionStatus.granted;
    });

    if (status == PermissionStatus.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Izin kamera ditolak. Buka pengaturan aplikasi untuk memberikan izin.'),
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
    super.dispose();
  }

  void _processScanResult(String rawValue) {
    if (rawValue != _lastScannedCode) { // Hanya proses jika kode berbeda
      _lastScannedCode = rawValue; // Update kode terakhir
      final viewModel = Provider.of<StockOpnameInputViewModel>(context, listen: false);
      viewModel.processScannedCode(
        rawValue,
        widget.blok,
        widget.idLokasi,
        widget.noSO,
        onSaveComplete: (success, message) {
          setState(() {
            _isSaving = false;
            _saveMessage = '$message\nLabel : $rawValue'; // Gabungkan pesan dan hasil scan
          });
          // Hapus pesan setelah beberapa detik
          Future.delayed(const Duration(seconds: 3), () {
            setState(() {
              _saveMessage = '';
            });
            _lastScannedCode = null; // Reset setelah pesan hilang
          });
        },
      );
    } else {
      debugPrint('Duplicate scan detected, skipping.');
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final scanAreaSize = screenWidth * 0.6;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Lokasi ${widget.blok}, ${widget.idLokasi}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(isFlashOn ? Icons.flash_off : Icons.flash_on, color: Colors.white),
            onPressed: () {
              setState(() {
                isFlashOn = !isFlashOn;
              });
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
                  if (barcodes.isNotEmpty && barcodes.first != null) {
                    final String? rawValue = barcodes.first.rawValue; // Simpan rawValue di variabel lokal
                    if (rawValue != null && !_isDetected) { // Pastikan rawValue tidak null
                      setState(() {
                        _scanResult = rawValue;
                        _isDetected = true;
                      });
                      _animationController.forward(from: 0);

                      if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
                      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                        setState(() {
                          _isDetected = false;
                        });
                        _processScanResult(rawValue); // Panggil fungsi pemrosesan
                      });
                    }
                  }
                  else {
                    setState(() {
                      _scanResult = null;
                      _isDetected = false;
                    });
                  }
                } catch (e) {
                  debugPrint('Error during barcode detection: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Terjadi kesalahan saat memproses barcode.')),
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
                margin: const EdgeInsets.symmetric(horizontal: 20), // Tambahkan margin horizontal
                decoration: BoxDecoration(
                  color: _saveMessage.startsWith('Data berhasil') ? Colors.green : Colors.red,
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
          Align(
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: scanAreaSize,
              height: scanAreaSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isDetected ? Colors.greenAccent.withOpacity(0.8) : Colors.white.withOpacity(0.2),
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