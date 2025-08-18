import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/api_constants.dart';
import '../model/kd_bongkar_model.dart';

class KDBongkarViewModel extends ChangeNotifier {
  List<KDBongkarModel> _kdBongkarList = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<KDBongkarModel> get kdBongkarList => _kdBongkarList;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchKDBongkarList() async {
    print("🔄 [KDBongkarViewModel] fetchKDBongkarList dipanggil");

    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      print("🔑 Token: $token");

      if (token == null) {
        _errorMessage = 'Token tidak ditemukan.';
        _kdBongkarList = [];
        print("❌ Token tidak ditemukan.");
        return;
      }

      final response = await http.get(
        Uri.parse(ApiConstants.listNoKD),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print("📡 Status code response: ${response.statusCode}");
      print("📦 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _kdBongkarList = data.map((item) => KDBongkarModel.fromJson(item)).toList();
        _errorMessage = '';
        print("✅ Berhasil memuat ${_kdBongkarList.length} data.");
      } else {
        final responseBody = json.decode(response.body);
        _errorMessage = responseBody['message'] ?? 'Gagal mengambil data.';
        _kdBongkarList = [];
        print("❌ Gagal memuat data. Pesan: $_errorMessage");
      }
    } catch (e) {
      _errorMessage = 'Gagal terhubung ke server.';
      _kdBongkarList = [];
      print("❌ Exception: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
      print("🏁 Selesai fetchKDBongkarList");
    }
  }

}
