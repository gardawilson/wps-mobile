// lib/core/auth/token_provider.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Kontrak pengambil token (bisa diganti ke SecureStorage, dsb).
abstract class TokenProvider {
  Future<String?> getToken();
}

class SharedPrefsTokenProvider implements TokenProvider {
  static const _kTokenKey = 'token';

  @override
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kTokenKey);
  }

  /// Opsional: simpan/hapus token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
  }
}
