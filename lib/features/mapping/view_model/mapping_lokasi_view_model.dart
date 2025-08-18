import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/mapping_lokasi_model.dart';
import '../../../core/models/combined_label_model.dart';
import '../../../core/models/label_detail_model.dart';
import '../../../core/models/label_response_model.dart'; // Add this import
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/api_constants.dart';

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

  // Add new properties for using LabelResponseModel
  LabelResponseModel? labelResponse;
  LabelSummary? summary;

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
    labelResponse = null; // Reset response model
    summary = null; // Reset summary
    notifyListeners();

    print("🔍 Fetch Data: FilterBy: $filterBy, IdLokasi: $idLokasi");

    try {
      final uri = Uri.parse(ApiConstants.labelList(
        page: 1,
        pageSize: initialPageSize,
        filterBy: filterBy,
        idLokasi: idLokasi,
      ));

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

        try {
          // Use LabelResponseModel instead of manual parsing
          labelResponse = LabelResponseModel.fromJson(data);

          // Extract data from model
          noLabelList = labelResponse!.noLabelList;
          noLabelFound = labelResponse!.noLabelFound;
          totalData = labelResponse!.totalData;
          summary = labelResponse!.summary;

          // Handle blokList (this seems to be separate from LabelResponseModel)
          final List<dynamic> lokasiData = data['mstLokasi'] ?? [];
          blokList = lokasiData.map((json) => MappingLokasiModel.fromJson(json)).toList();

          hasMoreData = labelResponse!.hasNextPage;
          errorMessage = '';
          currentStart += noLabelList.length;

          print("📊 Total labels loaded: ${noLabelList.length}");
          print("📈 Summary - Total M3: ${summary?.formattedTotalM3}, Total Jumlah: ${summary?.formattedTotalJumlah}");
          print("📄 Pagination: ${labelResponse!.currentDataRange}");
          print("📊 Progress: ${labelResponse!.loadedPercentage.toStringAsFixed(1)}%");

        } catch (e) {
          print("❌ Error parsing with LabelResponseModel: $e");
          print("📋 Falling back to manual parsing");

          // Fallback to manual parsing if model parsing fails
          final List<dynamic> lokasiData = data['mstLokasi'] ?? [];
          final List<dynamic> noSOData = data['noLabelList'] ?? [];

          noLabelFound = data['noLabelFound'] ?? true;
          totalData = data['totalData'] ?? 0;

          blokList = lokasiData.map((json) => MappingLokasiModel.fromJson(json)).toList();

          noLabelList = noSOData.map((json) {
            try {
              return CombinedLabelModel.fromJson(json);
            } catch (e) {
              print("❌ Error parsing label data: $e");
              return CombinedLabelModel(
                combinedLabel: json['CombinedLabel'] ?? 'Unknown',
                labelType: json['LabelType'],
                labelLocation: json['LabelLocation'],
                details: [],
              );
            }
          }).toList();

          hasMoreData = noLabelList.length < totalData;
          errorMessage = '';
          currentStart += noLabelList.length;
        }
      } else {
        errorMessage = 'Gagal memuat data (${response.statusCode}): ${response.body}';
      }
    } catch (e) {
      errorMessage = 'Error: $e';
      print("❌ Fetch Data Error: $e");
    } finally {
      isLoading = false;
      isInitialLoading = false;
      isFilterLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreData() async {
    if (isLoading || !hasMoreData) return;

    // Use the helper method from LabelResponseModel if available
    if (labelResponse != null && !labelResponse!.hasNextPage) {
      hasMoreData = false;
      return;
    }

    isLoading = true;
    notifyListeners();

    int nextPage = labelResponse?.nextPage ?? ((currentStart ~/ loadMoreSize) + 1);

    try {
      final uri = Uri.parse(ApiConstants.labelList(
        page: nextPage,
        pageSize: loadMoreSize,
        filterBy: currentFilter,
        idLokasi: currentLocation,
      ));

      print("🌐 Request URL: ${uri.toString()}");

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

        try {
          // Parse new response using LabelResponseModel
          final newLabelResponse = LabelResponseModel.fromJson(data);

          if (newLabelResponse.noLabelList.isEmpty) {
            hasMoreData = false;
            notifyListeners();
            return;
          }

          // Add new data to existing list
          noLabelList.addAll(newLabelResponse.noLabelList);

          // Update response object for pagination info
          labelResponse = LabelResponseModel(
            noLabelList: noLabelList,
            noLabelFound: newLabelResponse.noLabelFound,
            currentPage: newLabelResponse.currentPage,
            pageSize: newLabelResponse.pageSize,
            totalData: newLabelResponse.totalData,
            totalPages: newLabelResponse.totalPages,
            summary: newLabelResponse.summary,
          );

          // Update summary if available
          if (newLabelResponse.summary != null) {
            summary = newLabelResponse.summary;
          }

          hasMoreData = labelResponse!.hasNextPage;
          errorMessage = '';

          print("📊 Total labels after load more: ${noLabelList.length}");
          print("📄 Current page: ${labelResponse!.currentPage}/${labelResponse!.totalPages}");
          print("📊 Data range: ${labelResponse!.currentDataRange}");
          print("📈 Loaded percentage: ${labelResponse!.loadedPercentage.toStringAsFixed(1)}%");

        } catch (e) {
          print("❌ Error parsing load more with LabelResponseModel: $e");
          print("📋 Falling back to manual parsing");

          // Fallback to manual parsing
          final List<dynamic> newData = data['noLabelList'] ?? [];

          if (newData.isEmpty) {
            hasMoreData = false;
            notifyListeners();
            return;
          }

          final List<CombinedLabelModel> newLabels = newData.map((json) {
            try {
              return CombinedLabelModel.fromJson(json);
            } catch (e) {
              print("❌ Error parsing load more data: $e");
              return CombinedLabelModel(
                combinedLabel: json['CombinedLabel'] ?? 'Unknown',
                labelType: json['LabelType'],
                labelLocation: json['LabelLocation'],
                details: [],
              );
            }
          }).toList();

          noLabelList.addAll(newLabels);
          hasMoreData = noLabelList.length < totalData;
          currentStart += loadMoreSize;
          errorMessage = '';
        }
      } else {
        errorMessage = 'Gagal memuat data tambahan.';
      }
    } catch (e) {
      errorMessage = 'Error: $e';
      print("❌ Load More Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Helper methods untuk mendapatkan informasi agregat
  int getTotalDetailsCount() {
    return noLabelList.fold(0, (sum, label) => sum + label.totalDetails);
  }

  int getTotalBatangCount() {
    return noLabelList.fold(0, (sum, label) => sum + label.totalBatang);
  }

  List<CombinedLabelModel> getLabelsWithDetails() {
    return noLabelList.where((label) => label.hasDetails).toList();
  }

  List<CombinedLabelModel> getLabelsWithoutDetails() {
    return noLabelList.where((label) => !label.hasDetails).toList();
  }

  // Method untuk mendapatkan detail berdasarkan label
  List<LabelDetailModel> getDetailsByLabel(String labelName) {
    final label = noLabelList.firstWhere(
          (label) => label.combinedLabel == labelName,
      orElse: () => CombinedLabelModel(combinedLabel: ''),
    );
    return label.details;
  }

  // New helper methods that utilize the LabelResponseModel's capabilities

  // Get pagination info
  String get paginationInfo => labelResponse?.currentDataRange ?? '';

  // Get loading percentage
  double get loadingPercentage => labelResponse?.loadedPercentage ?? 0.0;

  // Get summary info
  String get totalM3Formatted => summary?.formattedTotalM3 ?? '0.00';
  String get totalJumlahFormatted => summary?.formattedTotalJumlah ?? '0';
  double get totalM3AsDouble => summary?.totalM3AsDouble ?? 0.0;
  int get totalJumlah => summary?.totalJumlah ?? 0;

  // Check if we have summary data
  bool get hasSummary => summary != null;

  // Get current page info
  int get currentPage => labelResponse?.currentPage ?? 1;
  int get totalPages => labelResponse?.totalPages ?? 1;
  bool get hasNextPage => labelResponse?.hasNextPage ?? false;
  bool get hasPreviousPage => labelResponse?.hasPreviousPage ?? false;

  // Get page size info
  int get pageSize => labelResponse?.pageSize ?? initialPageSize;
  int get currentPageItemCount => labelResponse?.currentPageItemCount ?? noLabelList.length;

  // Check if we have data
  bool get hasData => labelResponse?.hasData ?? noLabelList.isNotEmpty;

  void resetData() {
    noLabelList.clear();
    totalData = 0;
    hasMoreData = true;
    errorMessage = '';
    labelResponse = null;
    summary = null;
    notifyListeners();
  }

  Future<void> processScannedCode(
      String scannedCode,
      String idLokasi, {
        Function(bool, int, String)? onSaveComplete,
        bool forceSave = false,
      }) async {
    isSaving = true;
    saveMessage = 'Menyimpan...';
    notifyListeners();

    try {
      final url = Uri.parse(ApiConstants.checkLabel);
      String? token = await _getToken();

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      if (token == null || token.isEmpty) {
        saveMessage = 'Token tidak ditemukan. Silakan login ulang.';
        onSaveComplete?.call(false, 401, saveMessage);
        isSaving = false;
        notifyListeners();
        return;
      }

      if (idLokasi.isEmpty) {
        saveMessage = 'IdLokasi tidak boleh kosong.';
        onSaveComplete?.call(false, 400, saveMessage);
        isSaving = false;
        notifyListeners();
        return;
      }

      final body = jsonEncode({
        'resultscanned': scannedCode,
        'idlokasi': idLokasi,
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        saveMessage = 'Data berhasil disimpan!';
        onSaveComplete?.call(true, response.statusCode, saveMessage);
      } else {
        final responseJson = jsonDecode(response.body);
        saveMessage = responseJson['message'] ?? 'Gagal menyimpan';
        onSaveComplete?.call(false, response.statusCode, saveMessage);
      }
    } catch (e) {
      saveMessage = 'Terjadi kesalahan: $e';
      onSaveComplete?.call(false, 500, saveMessage);
      print("❌ Process Scanned Code Error: $e");
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> updateScannedCode(
      List<String> scannedCodes,
      String idLokasi, {
        Function(bool, int, String)? onSaveComplete,
        bool forceSave = false,
      }) async {
    isSaving = true;
    saveMessage = 'Menyimpan...';
    notifyListeners();

    try {
      final url = Uri.parse(ApiConstants.saveChanges);
      String? token = await _getToken();

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      if (token == null || token.isEmpty) {
        saveMessage = 'Token tidak ditemukan. Silakan login ulang.';
        onSaveComplete?.call(false, 401, saveMessage);
        isSaving = false;
        notifyListeners();
        return;
      }

      if (idLokasi.isEmpty) {
        saveMessage = 'IdLokasi tidak boleh kosong.';
        onSaveComplete?.call(false, 400, saveMessage);
        isSaving = false;
        notifyListeners();
        return;
      }

      final body = jsonEncode({
        'resultscannedList': scannedCodes,
        'idlokasi': idLokasi,
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        saveMessage = 'Data berhasil disimpan!';
        onSaveComplete?.call(true, response.statusCode, saveMessage);
      } else {
        final responseJson = jsonDecode(response.body);
        saveMessage = responseJson['message'] ?? 'Gagal menyimpan';
        onSaveComplete?.call(false, response.statusCode, saveMessage);
      }
    } catch (e) {
      saveMessage = 'Terjadi kesalahan: $e';
      onSaveComplete?.call(false, 500, saveMessage);
      print("❌ Update Scanned Code Error: $e");
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}