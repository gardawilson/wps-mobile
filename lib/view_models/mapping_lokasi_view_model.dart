import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/mapping_lokasi_model.dart';
import '../models/combined_label_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MappingLokasiViewModel extends ChangeNotifier {
  String errorMessage = '';
  String? currentFilter;
  String? currentLocation;

  int initialPageSize = 50;
  int loadMoreSize = 25;
  int totalData = 0;
  int currentStart = 0;
  List<CombinedLabelModel> noLabelList = [];
  bool noLabelFound = true;
  bool hasMoreData = true;

  bool isLoading = false;
  bool isInitialLoading = false;
  bool isFilterLoading = false;

  bool isSaving = false;
  String saveMessage = '';

  List<MappingLokasiModel> blokList = [];

  // Fungsi untuk mengambil token dari SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchData({String? filterBy, String? idLokasi, bool isInitial = false, bool isFilter = false}) async {
    isInitialLoading = isInitial;
    isFilterLoading = isFilter;
    isLoading = true;
    errorMessage = '';
    noLabelList = [];
    currentStart = 0;
    hasMoreData = true;
    noLabelFound = true;
    currentFilter = filterBy;
    currentLocation = idLokasi;
    notifyListeners();

    print("🔍 Fetch Data: FilterBy: $filterBy, IdLokasi: $idLokasi");

    try {
      final uri = Uri.parse(
          'http://192.168.11.153:5000/api/label-list?page=1&pageSize=$initialPageSize&filterBy=${filterBy ?? 'all'}&idlokasi=${idLokasi ?? 'all'}'
      );

      String? token = await _getToken();
      if (token == null) {
        errorMessage = "Token tidak ditemukan. Harap login ulang.";
        notifyListeners();
        return;
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(uri, headers: headers);
      print("📩 Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> lokasiData = data['mstLokasi'] ?? [];
        final List<dynamic> noSOData = data['noLabelList'] ?? [];

        noLabelFound = data['noLabelFound'] ?? true;
        totalData = data['totalData'] ?? 0;

        blokList = lokasiData.map((json) => MappingLokasiModel.fromJson(json)).toList();
        noLabelList = noSOData.map((json) => CombinedLabelModel.fromJson(json)).toList();

        hasMoreData = noLabelList.length < totalData;
        errorMessage = '';
        currentStart += noLabelList.length;
      } else {
        errorMessage = 'Gagal memuat data (${response.statusCode}): ${response.body}';
      }
    } catch (e) {
      errorMessage = 'Error: $e';
    } finally {
      isLoading = false;
      isInitialLoading = false;
      isFilterLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreData() async {
    if (isLoading || !hasMoreData) return;
    isLoading = true;
    notifyListeners();

    int page = (currentStart ~/ loadMoreSize) + 1;

    try {
      final uri = Uri.parse(
          'http://192.168.11.153:5000/api/label-list?page=$page&pageSize=$loadMoreSize&filterBy=${currentFilter ?? 'all'}&idlokasi=${currentLocation ?? 'all'}'
      );

      String? token = await _getToken();
      if (token == null) {
        errorMessage = "Token tidak ditemukan.";
        notifyListeners();
        return;
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(uri, headers: headers);
      print("📩 Response Load More: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> newData = data['noLabelList'] ?? [];

        if (newData.isEmpty) {
          hasMoreData = false;
          notifyListeners();
          return;
        }

        noLabelList.addAll(newData.map((json) => CombinedLabelModel.fromJson(json)).toList());
        hasMoreData = noLabelList.length < totalData;
        currentStart += loadMoreSize;
        errorMessage = '';
      } else {
        errorMessage = 'Gagal memuat data tambahan.';
      }
    } catch (e) {
      errorMessage = 'Error: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void resetData() {
    noLabelList.clear();
    totalData = 0;
    hasMoreData = true;
    errorMessage = '';
    notifyListeners();
  }

  Future<void> processScannedCode(
      String scannedCode,
      String idLokasi, {
        Function(bool, int, String)? onSaveComplete,
        bool forceSave = false, // Flag untuk memaksa penyimpanan
      }) async {
    isSaving = true;
    saveMessage = 'Menyimpan...';
    notifyListeners();

    try {
      final url = Uri.parse('http://192.168.11.153:5000/api/label-list/mapping');
      String? token = await _getToken();

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      if (token == null || token.isEmpty) {
        saveMessage = 'Token tidak ditemukan. Silakan login ulang.';
        onSaveComplete?.call(false, 401, saveMessage); // Return status code 401
        isSaving = false;
        notifyListeners();
        return;
      }

      if (idLokasi.isEmpty) {
        saveMessage = 'IdLokasi tidak boleh kosong.';
        onSaveComplete?.call(false, 400, saveMessage); // Return status code 400
        isSaving = false;
        notifyListeners();
        return;
      }

      final body = jsonEncode({
        'resultscanned': scannedCode,
        'idlokasi': idLokasi,
        'forceSave': forceSave,  // Menggunakan flag forceSave
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Jika statusCode 201 atau jika forceSave true, simpan data meskipun tidak ada data
        saveMessage = 'Data berhasil disimpan!';
        onSaveComplete?.call(true, response.statusCode, saveMessage); // Return status code 201
      } else {
        final responseJson = jsonDecode(response.body);
        saveMessage = responseJson['message'] ?? 'Gagal menyimpan';
        onSaveComplete?.call(false, response.statusCode, saveMessage); // Return status code error
      }
    } catch (e) {
      saveMessage = 'Terjadi kesalahan: $e';
      onSaveComplete?.call(false, 500, saveMessage); // Return status code 500 for error
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
