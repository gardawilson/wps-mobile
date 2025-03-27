import 'package:flutter/material.dart';
import '../view_models/login_view_model.dart';
import '../models/user_model.dart';
import '../view_models/update_view_model.dart';
import '../models/update_model.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final LoginViewModel _viewModel = LoginViewModel();
  final UpdateViewModel _updateViewModel = UpdateViewModel();
  bool _isPasswordVisible = false;
  bool _isCheckingUpdate = false;



  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    setState(() => _isCheckingUpdate = true);

    try {
      final updateInfo = await _updateViewModel.checkForUpdate();
      if (updateInfo != null && mounted) {
        _showUpdateDialog(updateInfo);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memeriksa update: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isCheckingUpdate = false);
      }
    }
  }

  void _showUpdateDialog(UpdateInfo updateInfo) {
    int downloadProgress = 0;
    bool isDownloading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Pembaruan Tersedia'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Versi baru: ${updateInfo.version}'),
                const SizedBox(height: 10),
                const Text('Perubahan:'),
                Text(updateInfo.changelog),
                if (isDownloading) ...[
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: downloadProgress / 100,
                  ),
                  Text('$downloadProgress% selesai'),
                ],
              ],
            ),
            actions: [
              if (!isDownloading)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Nanti'),
                ),
              TextButton(
                onPressed: isDownloading
                    ? null
                    : () async {
                  setState(() => isDownloading = true);
                  try {
                    // 1. Request permission
                    if (await Permission.requestInstallPackages.request() != PermissionStatus.granted) {
                      throw Exception('Install permission denied');
                    }

                    // 2. Download file
                    final file = await _updateViewModel.downloadUpdate(
                      updateInfo.fileName,
                          (progress) => setState(() => downloadProgress = progress),
                    );

                    if (file == null) throw Exception('Download failed');

                    // 3. Verifikasi file sebelum install
                    if (!file.existsSync() || await file.length() == 0) {
                      throw Exception('Downloaded file is invalid');
                    }

                    // 4. Install APK
                    final result = await OpenFile.open(file.path, type: 'application/vnd.android.package-archive');

                    if (result.type != ResultType.done) {
                      throw Exception('Install failed: ${result.message}');
                    }

                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                      setState(() => isDownloading = false);
                    }
                  }
                },
                child: Text(isDownloading ? 'Mengunduh...' : 'Perbarui'),
              ),
            ],
          );
        },
      ),
    );
  }


  void _login() async {
    User user = User(
      username: _usernameController.text,
      password: _passwordController.text,
    );

    bool isValid = await _viewModel.validateLogin(user);

    if (isValid) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid login credentials')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background coklat penuh di belakang
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Color(0xFF755330), // Mengganti warna background dengan #6c3c0c
          ),

          // Top section (header) dengan logo di depan background coklat
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 220,
              width: double.infinity,
              color: Colors.transparent, // Menggunakan transparan agar background coklat tetap terlihat
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Transform.scale(
                      scale: 3.0, // Atur angka ini untuk zoom gambar
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(Colors.white.withOpacity(1.0), BlendMode.srcATop),
                        child: Image.asset(
                          'assets/images/icon_without_bg.png',  // Ganti dengan path logo Anda
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Halaman login di depan background coklat
          Positioned(
            top: 220, // Agar login muncul tepat setelah header
            left: 0,
            right: 0,
            bottom: 0, // Agar login container mengisi sisa layar
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Username',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible, // Menyembunyikan atau menampilkan password
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off, // Ganti ikon berdasarkan status
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible; // Toggle status password
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF755330),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: RichText(
                        text: TextSpan(
                          text: 'Don\'t have any account? ',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 14,
                          ),
                          children: const [
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}