import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/api_constants.dart';
import '../model/kayu_bulat_model.dart';

class KayuBulatViewModel extends ChangeNotifier {
  List<KayuBulatModel> _list = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<KayuBulatModel> get list => _list;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchAll() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) throw Exception("Token tidak ditemukan.");

      final uri = Uri.parse("${ApiConstants.baseUrl}/api/kayu-bulat");
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          _list = data.map((e) => KayuBulatModel.fromJson(e)).toList();
          _errorMessage = '';
        } else {
          _errorMessage = body['message'] ?? "Gagal mengambil data.";
          _list = [];
        }
      } else {
        _errorMessage = "Server error: ${response.statusCode}";
        _list = [];
      }
    } catch (e) {
      _errorMessage = "Terjadi error: $e";
      _list = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
