import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stock_opname_model.dart';

class StockOpnameViewModel extends ChangeNotifier {
  List<StockOpname> _stockOpnameList = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<StockOpname> get stockOpnameList => _stockOpnameList;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Fungsi untuk mengambil token dari SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Mengambil token yang disimpan
  }

  // Fungsi untuk mengambil data stock opname
  Future<void> fetchStockOpname() async {
    _isLoading = true;
    notifyListeners();

    const String apiUrl = 'http://192.168.11.153:5000/api/no-stock-opname';
    try {
      // Ambil token dari SharedPreferences
      String? token = await _getToken();

      if (token == null) {
        _errorMessage = 'No token found';
        _stockOpnameList = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token', // Menambahkan token di header Authorization
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _stockOpnameList = data.map((item) => StockOpname.fromJson(item)).toList();
        _errorMessage = '';
      } else if (response.statusCode == 401) {
        _errorMessage = 'Unauthorized: Token is invalid or expired';
        _stockOpnameList = [];
      } else {
        _errorMessage = 'Failed to load stock opname data';
        _stockOpnameList = [];
      }
    } catch (error) {
      _errorMessage = 'Failed to connect to the server';
      _stockOpnameList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
