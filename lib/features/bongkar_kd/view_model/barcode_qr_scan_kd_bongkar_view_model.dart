import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BarcodeQrScanKdBongkarViewModel extends ChangeNotifier {
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Check validity of label first
  Future<void> checkLabel({
    required String noST,
    required String noProcKD,
    required Function(bool success, bool requireConfirmation, String message) onCheckResult,
  }) async {
    try {
      final token = await getToken();
      final url = ApiConstants.checkKdBongkar;

      print('📤 [DEBUG] Check POST URL: $url');
      print('📦 [DEBUG] Check Payload: {noST: $noST, noProcKD: $noProcKD}');
      print('🔑 [DEBUG] Bearer Token: $token');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'noST': noST,
          'noProcKD': noProcKD,
        }),
      );

      print('📥 [DEBUG] Check Response Status Code: ${response.statusCode}');
      print('📄 [DEBUG] Check Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final success = data['success'] ?? false;
        final requireConfirmation = data['requireConfirmation'] ?? false;
        final message = data['message'] ?? '';

        onCheckResult(success, requireConfirmation, message);
      } else {
        final data = jsonDecode(response.body);
        onCheckResult(false, false, data['message'] ?? 'Gagal memvalidasi label');
      }
    } catch (e) {
      print('❌ [ERROR] Exception saat check label: $e');
      onCheckResult(false, false, 'Error: ${e.toString()}');
    }
  }

  // Update location of label
  Future<void> updateLokasi({
    required String noST,
    required String idLokasi,
    required Function(bool success, int statusCode, String message) onResult,
  }) async {
    try {
      final token = await getToken();
      final url = ApiConstants.updateKdBongkar;

      print('📤 [DEBUG] Update POST URL: $url');
      print('📦 [DEBUG] Update Payload: {noST: $noST, idLokasi: $idLokasi}');
      print('🔑 [DEBUG] Bearer Token: $token');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'noST': noST,
          'idLokasi': idLokasi,
        }),
      );

      print('📥 [DEBUG] Update Response Status Code: ${response.statusCode}');
      print('📄 [DEBUG] Update Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        onResult(true, response.statusCode, data['message'] ?? 'Lokasi berhasil diperbarui');
      } else {
        onResult(false, response.statusCode, data['message'] ?? 'Gagal memperbarui lokasi');
      }
    } catch (e) {
      print('❌ [ERROR] Exception saat update lokasi: $e');
      onResult(false, 500, 'Error: ${e.toString()}');
    }
  }

  // Main process flow - first check, then update if needed
  Future<void> processScannedLabel({
    required String label,        // Ini adalah NoST
    required String noProcKD,     // Parameter untuk check
    required String idLokasi,     // Lokasi baru untuk label
    required Function(bool success, int statusCode, String message) onResult,
    required Function(String message, VoidCallback onConfirm) onNeedConfirmation,
  }) async {
    // Step 1: Check label validity first
    await checkLabel(
      noST: label,
      noProcKD: noProcKD,
      onCheckResult: (success, requireConfirmation, message) {
        if (success && !requireConfirmation) {
          // Valid dan sudah digunakan - langsung update lokasi
          updateLokasi(
            noST: label,
            idLokasi: idLokasi,
            onResult: onResult,
          );
        } else if (requireConfirmation) {
          // Belum digunakan - butuh konfirmasi user
          onNeedConfirmation(message, () {
            // User konfirmasi - lanjut update lokasi
            updateLokasi(
              noST: label,
              idLokasi: idLokasi,
              onResult: onResult,
            );
          });
        } else {
          // Error atau invalid
          onResult(false, 400, message);
        }
      },
    );
  }
}