import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/kd_bongkar_detail_before_model.dart';
import '../model/kd_bongkar_detail_after_model.dart';
import '../../../constants/api_constants.dart';

class KDBongkarDetailViewModel extends ChangeNotifier {
  // ===== BEFORE =====
  List<KDBongkarDetailBeforeModel> _beforeList = [];
  int _totalBefore = 0;
  String _totalM3Before = '0.0000';
  int _totalJumlahBefore = 0;

  // ===== AFTER =====
  List<KDBongkarDetailAfterModel> _afterList = [];
  int _totalAfter = 0;
  String _totalM3After = '0.0000';
  int _totalJumlahAfter = 0;

  // ===== COMMON STATE =====
  bool _isLoading = false;
  String _errorMessage = '';

  // Getter BEFORE
  List<KDBongkarDetailBeforeModel> get beforeList => _beforeList;
  int get totalBefore => _totalBefore;
  String get totalM3Before => _totalM3Before;
  int get totalJumlahBefore => _totalJumlahBefore;

  // Getter AFTER
  List<KDBongkarDetailAfterModel> get afterList => _afterList;
  int get totalAfter => _totalAfter;
  String get totalM3After => _totalM3After;
  int get totalJumlahAfter => _totalJumlahAfter;

  // Getter COMMON
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Helper getter untuk total gabungan
  String get totalM3Combined {
    double beforeValue = double.tryParse(_totalM3Before) ?? 0.0;
    double afterValue = double.tryParse(_totalM3After) ?? 0.0;
    return (beforeValue + afterValue).toStringAsFixed(4);
  }

  int get totalJumlahCombined => _totalJumlahBefore + _totalJumlahAfter;

  // Ambil token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fetch BEFORE data
  Future<void> fetchBefore(String noProcKD) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _errorMessage = 'Token tidak ditemukan.';
        _beforeList = [];
        _totalBefore = 0;
        _totalM3Before = '0.0000';
        _totalJumlahBefore = 0;
        return;
      }

      final url = Uri.parse('${ApiConstants.listNoKD}/$noProcKD/detail');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final data = jsonBody['data'];

        _beforeList = (data['labels'] as List)
            .map((item) => KDBongkarDetailBeforeModel.fromJson(item))
            .toList();

        _totalBefore = data['totalLabel'] ?? 0;

        // Ambil summary data
        final summary = data['summary'];
        _totalM3Before = summary?['totalM3'] ?? '0.0000';
        _totalJumlahBefore = summary?['totalJumlah'] ?? 0;

        _errorMessage = '';
      } else {
        final responseBody = json.decode(response.body);
        _errorMessage = responseBody['message'] ?? 'Gagal mengambil data BEFORE.';
        _beforeList = [];
        _totalBefore = 0;
        _totalM3Before = '0.0000';
        _totalJumlahBefore = 0;
      }
    } catch (e) {
      _errorMessage = 'Gagal terhubung ke server (BEFORE).';
      _beforeList = [];
      _totalBefore = 0;
      _totalM3Before = '0.0000';
      _totalJumlahBefore = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch AFTER data
  Future<void> fetchAfter(String noProcKD) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _errorMessage = 'Token tidak ditemukan.';
        _afterList = [];
        _totalAfter = 0;
        _totalM3After = '0.0000';
        _totalJumlahAfter = 0;
        return;
      }

      final url = Uri.parse('${ApiConstants.listNoKD}/$noProcKD/detail-checked');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final data = jsonBody['data'];

        _afterList = (data['labels'] as List)
            .map((item) => KDBongkarDetailAfterModel.fromJson(item))
            .toList();

        _totalAfter = data['totalLabel'] ?? 0;

        // Ambil summary data
        final summary = data['summary'];
        _totalM3After = summary?['totalM3'] ?? '0.0000';
        _totalJumlahAfter = summary?['totalJumlah'] ?? 0;

        _errorMessage = '';
      } else {
        final responseBody = json.decode(response.body);
        _errorMessage = responseBody['message'] ?? 'Gagal mengambil data AFTER.';
        _afterList = [];
        _totalAfter = 0;
        _totalM3After = '0.0000';
        _totalJumlahAfter = 0;
      }
    } catch (e) {
      _errorMessage = 'Gagal terhubung ke server (AFTER).';
      _afterList = [];
      _totalAfter = 0;
      _totalM3After = '0.0000';
      _totalJumlahAfter = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch both (sekaligus before & after)
  Future<void> fetchAll(String noProcKD) async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      fetchBefore(noProcKD),
      fetchAfter(noProcKD),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  // Helper methods untuk UI
  bool hasDetailsInBefore() {
    return _beforeList.any((item) => item.details != null && item.details!.isNotEmpty);
  }

  bool hasDetailsInAfter() {
    return _afterList.any((item) => item.details != null && item.details!.isNotEmpty);
  }

  // Method untuk clear data
  void clearData() {
    _beforeList.clear();
    _afterList.clear();
    _totalBefore = 0;
    _totalAfter = 0;
    _totalM3Before = '0.0000';
    _totalJumlahBefore = 0;
    _totalM3After = '0.0000';
    _totalJumlahAfter = 0;
    _errorMessage = '';
    notifyListeners();
  }
}