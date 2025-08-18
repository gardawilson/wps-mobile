import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/nyangkut_detail_model.dart';
import '../../../constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NyangkutDetailViewModel extends ChangeNotifier {
  List<NyangkutDetailModel> labelList = [];
  bool isLoading = false;
  bool isInitialLoading = false;
  bool hasMoreData = true;
  String errorMessage = '';
  int totalData = 0;
  int currentPage = 1;
  int pageSize = 20;
  String? currentFilter;
  String? currentLocation;
  bool noLabelFound = true;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Panggil saat awal atau saat filter berubah
  Future<void> fetchInitialData(String noNyangkut, {String? filterBy, String? idLokasi}) async {
    currentPage = 1;
    isInitialLoading = true;
    isLoading = true;
    labelList.clear();
    hasMoreData = true;
    errorMessage = '';
    currentFilter = filterBy;
    currentLocation = idLokasi;
    notifyListeners();

    await _fetchData(noNyangkut);
  }

  // Load More saat scroll bawah
  Future<void> loadMoreData(String noNyangkut) async {
    if (isLoading || !hasMoreData) return;
    isLoading = true;
    notifyListeners();

    currentPage++;
    await _fetchData(noNyangkut);
  }

  Future<void> _fetchData(String noNyangkut) async {
    try {
      final token = await _getToken();
      final uri = Uri.parse(ApiConstants.labelNyangkut(
        nonyangkut: noNyangkut,
        page: currentPage,
        pageSize: pageSize,
        filterBy: currentFilter,
        idLokasi: currentLocation,
      ));

      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = jsonData['data'];

        final List<NyangkutDetailModel> fetchedList =
        (data['noLabelList'] as List).map((e) => NyangkutDetailModel.fromJson(e)).toList();

        labelList.addAll(fetchedList);
        totalData = data['pagination']['totalData'];
        hasMoreData = labelList.length < totalData;
        noLabelFound = data['noLabelFound'];
      } else {
        errorMessage = 'Gagal mengambil data (${response.statusCode})';
        hasMoreData = false;
      }
    } catch (e) {
      errorMessage = 'Terjadi kesalahan: $e';
      hasMoreData = false;
    } finally {
      isInitialLoading = false;
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    labelList.clear();
    currentPage = 1;
    hasMoreData = true;
    errorMessage = '';
    notifyListeners();
  }

  // Kirim hasil scan ke endpoint
  Future<void> processScannedLabel({
    required String nonyangkut,
    required String label,
    required Function(bool success, int statusCode, String message) onResult,
  }) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse(ApiConstants.scanLabelNyangkut(nonyangkut)),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'label': label}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        // ✅ Setelah berhasil simpan, fetch ulang data
        await fetchInitialData(nonyangkut,
          filterBy: currentFilter,
          idLokasi: currentLocation,
        );

        onResult(true, response.statusCode, 'Data berhasil disimpan');
      } else {
        onResult(false, response.statusCode, data['message'] ?? 'Gagal menyimpan');
      }
    } catch (e) {
      onResult(false, 500, 'Error: ${e.toString()}');
    }
  }


  // Untuk reset halaman saat filter berubah
  void resetPagination() {
    currentPage = 1;
    labelList.clear();
    notifyListeners();
  }
}
