import 'dart:async'; // Import Timer
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../view_model/barcode_qr_scan_kd_bongkar_view_model.dart';
import '../view_model/kd_bongkar_detail_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';


class BarcodeQrScanKdBongkarScreen extends StatefulWidget {
  final String noProcKD;
  final String selectedLocation;

  const BarcodeQrScanKdBongkarScreen({
    Key? key,
    required this.noProcKD,
    required this.selectedLocation,
  }) : super(key: key);

  @override
  _BarcodeQrScanKdBongkarScreenState createState() => _BarcodeQrScanKdBongkarScreenState();
}

class _BarcodeQrScanKdBongkarScreenState extends State<BarcodeQrScanKdBongkarScreen> with SingleTickerProviderStateMixin {
  final MobileScannerController cameraController = MobileScannerController();
  String? _scanResult;
  bool isFlashOn = false;
  bool hasCameraPermission = false;
  late AnimationController _animationController;
  bool _isDetected = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

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

  // Dialog konfirmasi untuk label yang belum digunakan
  void _showConfirmationDialog(String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Reset state untuk scan berikutnya
                _lastScannedCode = null;
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm(); // Lanjutkan proses update lokasi
              },
              child: const Text('Ya, Lanjutkan'),
            ),
          ],
        );
      },
    );
  }

  void _processScanResult(String rawValue) async {
    if (rawValue != _lastScannedCode) {
      _lastScannedCode = rawValue;

      final viewModel = Provider.of<BarcodeQrScanKdBongkarViewModel>(context, listen: false);
      setState(() {
        _isSaving = true;
      });

      viewModel.processScannedLabel(
        label: rawValue,
        noProcKD: widget.noProcKD, // Parameter untuk check endpoint
        idLokasi: widget.selectedLocation,
        onResult: (success, statusCode, message) {
          setState(() {
            _isSaving = false;
            _saveMessage = '$message\nLabel : $rawValue';
          });

          if (success) {
            _audioPlayer.setPlaybackRate(2.0);
            _audioPlayer.play(AssetSource('sounds/accepted.mp3'));

            // Refresh total label
            final kdDetailViewModel = Provider.of<KDBongkarDetailViewModel>(context, listen: false);
            kdDetailViewModel.fetchBefore(widget.noProcKD);
            kdDetailViewModel.fetchAfter(widget.noProcKD);
          } else {
            _audioPlayer.setPlaybackRate(2.0);
            _audioPlayer.play(AssetSource('sounds/denied.mp3'));
            Vibration.vibrate(duration: 1000);
          }

          Future.delayed(const Duration(seconds: 3), () {
            setState(() {
              _saveMessage = '';
            });
            _lastScannedCode = null;
          });
        },
        onNeedConfirmation: (message, onConfirm) {
          setState(() {
            _isSaving = false;
          });

          // Tampilkan dialog konfirmasi
          _showConfirmationDialog(message, () {
            // User konfirmasi - lanjutkan dengan loading state
            setState(() {
              _isSaving = true;
            });
            onConfirm(); // Callback akan memanggil onResult di atas
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
    final detailVM = context.watch<KDBongkarDetailViewModel>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '${widget.noProcKD} (${detailVM.totalBefore})',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white, // Set background color to white
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // Set icon color to black
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
                  color: _saveMessage.contains('berhasil') ? Colors.green : Colors.red,
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

          // Ikon Status (check.png atau cross.png)
          if (_saveMessage.isNotEmpty) // Hanya tampilkan ikon jika ada pesan
            Positioned(
              top: 150, // Atur jarak dari bawah (sesuaikan dengan kebutuhan)
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _saveMessage.contains('berhasil')
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