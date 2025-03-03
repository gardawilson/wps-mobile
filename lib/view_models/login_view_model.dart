import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import '../models/user_model.dart';

class LoginViewModel {
  Future<bool> validateLogin(User user) async {
    final url = Uri.parse('http://192.168.11.153:5000/api/login'); // Ganti dengan IP server yang benar

    try {
      // Kirim request dengan header Content-Type: application/json
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',  // Pastikan Content-Type JSON
        },
        body: jsonEncode(user.toJson()),  // Mengirim data dalam format JSON
      );

      // Log status code dan body response untuk debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print('Login success: ${data['message']}');

        // Jika login berhasil, kita bisa mendapatkan token dari response
        String token = data['token'];

        // Simpan token menggunakan SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token); // Simpan token di SharedPreferences

        return true;
      } else {
        print('Login failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  }
}
