import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BarcodeQrScanLancarViewModel extends ChangeNotifier {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Kirim hasil scan ke endpoint
  Future<void> processScannedLabel({
    required String label,
    required Function(bool success, int statusCode, String message) onResult,
  }) async {
    try {
      final token = await _getToken();
      final url = ApiConstants.scanLabelLancar(label);

      // LOGGING untuk debug
      print('🔎 [DEBUG] API URL: $url');
      print('🔑 [DEBUG] Bearer Token: $token');
      print('🏷️ [DEBUG] Scanned Label: $label');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      // LOG RESPONSE
      print('📥 [DEBUG] Response Status Code: ${response.statusCode}');
      print('📄 [DEBUG] Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        onResult(true, response.statusCode, 'Label berhasil dilancarkan');
      } else {
        onResult(false, response.statusCode,
            data['message'] ?? 'Gagal melancarkan label');
      }
    } catch (e) {
      print('❌ [ERROR] Exception saat proses: $e');
      onResult(false, 500, 'Error: ${e.toString()}');
    }
  }
}

