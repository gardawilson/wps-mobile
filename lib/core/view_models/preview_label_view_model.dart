import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/label_model_st.dart';
import '../models/label_model_s4s.dart';
import '../../constants/api_constants.dart';


class PreviewLabelViewModel extends ChangeNotifier {
  dynamic label;   // Menyimpan data label yang didapatkan dari API (LabelModelST atau LabelModelS4S)
  bool isLoading = false;   // Menandakan status loading data
  String? errorMessage;    // Menyimpan pesan error jika terjadi kesalahan

  // Fungsi untuk mengambil token dari SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Mengambil token yang disimpan
  }

  // Fungsi untuk mengambil data label berdasarkan nolabel
  Future<void> fetchLabelData(String nolabel) async {
    isLoading = true;
    errorMessage = null; // Reset errorMessage sebelum memulai request
    notifyListeners();

    try {
      // Ambil token dari SharedPreferences
      String? token = await _getToken();

      if (token == null) {
        errorMessage = 'No token found. Please login again.';
        isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse(ApiConstants.labelData(nolabel)),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // Debug untuk melihat struktur data JSON
        print("Parsed Data: $data");

        // Memeriksa apakah header ada dan tidak kosong
        if (data['header'] != null && data['header'].isNotEmpty) {
          // Menentukan format model yang digunakan
          if (nolabel.startsWith('E')) {
            label = LabelModelST.fromJson(data);  // Format 'ST'
          } else if (nolabel.startsWith('R')) {
            label = LabelModelS4S.fromJson(data);  // Format 'S4S'
          }
          print("Label Data: ${label?.toString()}");
        } else {
          label = null;
          errorMessage = 'No data found for the provided label number.';
        }
      } else {
        errorMessage = 'Failed to load label data. Status code: ${response.statusCode}.';
      }
    } catch (e) {
      errorMessage = 'An error occurred while fetching label data: ${e.toString()}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
