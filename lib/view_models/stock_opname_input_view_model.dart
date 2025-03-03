import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/stock_opname_input_model.dart';
import '../models/combined_label_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class StockOpnameInputViewModel extends ChangeNotifier {
  String noSO = '';
  String tgl = '';
  String blok = '';
  String idLokasi = '';
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

  List<StockOpnameInputModel> blokList = [];

  bool isSaving = false;
  String saveMessage = '';

  List<String> scannedCodes = [];

  // Fungsi untuk mengambil token dari SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Mengambil token yang disimpan
  }


  Future<void> fetchData(String selectedNoSO, {String? filterBy, String? idLokasi, bool isInitial = false, bool isFilter = false}) async {
    noSO = selectedNoSO;
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

    // Cek nilai idLokasi yang diterima
    print("🔍 Fetch Data: NoSO: $selectedNoSO, FilterBy: $filterBy, IdLokasi: $idLokasi");

    try {
      final uri = Uri.parse(
          'http://192.168.11.153:5000/api/no-stock-opname/$selectedNoSO?page=1&pageSize=$initialPageSize&filterBy=${filterBy ?? 'all'}&idlokasi=${idLokasi ?? 'all'}'
      );

      print("🔍 URL Request: $uri"); // Log URL untuk memastikan parameter benar-benar dikirimkan

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> lokasiData = data['mstLokasi'];
        final List<dynamic> noSOData = data['noLabelList'];

        noLabelFound = data['noLabelFound'] ?? true;
        totalData = data['totalData'];

        blokList = lokasiData.map((json) => StockOpnameInputModel.fromJson(json)).toList();
        noLabelList = noSOData.map((json) => CombinedLabelModel.fromJson(json)).toList();

        hasMoreData = noLabelList.length < totalData;
        errorMessage = '';
        currentStart += noLabelList.length;
      } else {
        errorMessage = 'Failed to load data from API';
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


  Future<void> fetchInitialData(String selectedNoSO, {String? filterBy, String? idLokasi}) async {
    return fetchData(selectedNoSO, filterBy: filterBy, idLokasi: idLokasi, isInitial: true);
  }

  Future<void> fetchFilteredData(String selectedNoSO, {String? filterBy, String? idLokasi}) async {
    return fetchData(selectedNoSO, filterBy: filterBy, idLokasi: idLokasi, isFilter: true);
  }

  Future<void> loadMoreData(String selectedNoSO) async {
    if (isLoading || !hasMoreData) return;
    isLoading = true;
    notifyListeners();

    int page = currentStart ~/ loadMoreSize + 1;

    try {
      final uri = Uri.parse(
          'http://192.168.11.153:5000/api/no-stock-opname/$selectedNoSO?page=$page&pageSize=$loadMoreSize&filterBy=${currentFilter ?? 'all'}&idLokasi=${currentLocation ?? 'all'}');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> noSOData = data['noLabelList'];
        final List<CombinedLabelModel> newData =
        noSOData.map((json) => CombinedLabelModel.fromJson(json)).toList();
        if (newData.isEmpty) return;

        noLabelList.addAll(newData);
        hasMoreData = noLabelList.length < totalData;
        currentStart += loadMoreSize;

        errorMessage = '';
      } else {
        errorMessage = 'Failed to load data from API';
      }
    } catch (e) {
      errorMessage = 'Error: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateBlokAndLokasi(String selectedBlok) {
    blok = selectedBlok;
    final selectedBlokList = blokList.where((item) => item.blok == selectedBlok).toList();
    idLokasi = selectedBlokList.isNotEmpty ? selectedBlokList.first.idLokasi : '';
    notifyListeners();
  }

  void resetBlokAndLokasi() {
    blok = '';
    idLokasi = '';
    notifyListeners();
  }

  Future<void> processScannedCode(
      String scannedCode,
      String blok,
      String idLokasi,
      String noSO, {
        Function(bool, String)? onSaveComplete
      }) async {
    isSaving = true;
    saveMessage = 'Menyimpan...';
    notifyListeners();

    try {
      final url = Uri.parse('http://192.168.11.153:5000/api/no-stock-opname/$noSO/scan');
      String? token = await _getToken();

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Menambahkan token ke header Authorization
      };      // Ambil token dari SharedPreferences
      if (token == null || token.isEmpty) {
        saveMessage = 'Token tidak ditemukan. Silakan login ulang.';
        onSaveComplete?.call(false, saveMessage);
        isSaving = false;
        notifyListeners();
        return;
      }



      if (idLokasi.isEmpty) {
        saveMessage = 'IdLokasi tidak boleh kosong.';
        onSaveComplete?.call(false, saveMessage);
        isSaving = false;
        notifyListeners();
        return;
      }

      final body = jsonEncode({
        'resultscanned': scannedCode,
        'idlokasi': idLokasi,
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        saveMessage = 'Data berhasil disimpan!';
        onSaveComplete?.call(true, saveMessage);
      } else {
        final responseJson = jsonDecode(response.body);
        saveMessage = responseJson['message'] ?? 'Gagal menyimpan';
        onSaveComplete?.call(false, saveMessage);
      }
    } catch (e) {
      saveMessage = 'Terjadi kesalahan: $e';
      onSaveComplete?.call(false, saveMessage);
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  void clearScannedCodes() {
    scannedCodes.clear();
    notifyListeners();
  }
}
