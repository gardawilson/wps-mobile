// view_model/kayu_bulat_attachment_view_model.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../model/image_tier_model.dart';
import '../model/video_tier_model.dart';
import '../services/kayu_bulat_service.dart';

class KayuBulatAttachmentViewModel extends ChangeNotifier {
  final _service = KayuBulatService();

  bool _isUploading = false;
  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, dynamic>? _lastUploadResult;

  List<ImageTier> _imageTiers = [];
  List<VideoTier> _videoTiers = [];

  bool get isUploading => _isUploading;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Map<String, dynamic>? get lastUploadResult => _lastUploadResult;
  List<ImageTier> get imageTiers => _imageTiers;
  List<VideoTier> get videoTiers => _videoTiers;

  Future<void> uploadImage({
    required String noKayuBulat,
    required File file,
    required int tier,
    required int pcs,
  }) async {
    _isUploading = true;
    _errorMessage = '';
    _lastUploadResult = null;
    notifyListeners();

    try {
      final response = await _service.uploadImage(
        noKayuBulat: noKayuBulat,
        file: file,
        tier: tier,
        pcs: pcs,
      );

      if (response.statusCode == 200) {
        _lastUploadResult = json.decode(response.body);
      } else {
        final data = json.decode(response.body);
        _errorMessage = data['message'] ?? 'Upload gagal (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = "Terjadi error: $e";
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  // ⬇️⬇️ Update sesuai controller: noUrut & remark
  Future<void> uploadVideo({
    required String noKayuBulat,
    required File file,
    required int noUrut,
    String? remark,
  }) async {
    _isUploading = true;
    _errorMessage = '';
    _lastUploadResult = null;
    notifyListeners();

    try {
      final response = await _service.uploadVideo(
        noKayuBulat: noKayuBulat,
        file: file,
        noUrut: noUrut,
        remark: remark,
      );

      if (response.statusCode == 200) {
        _lastUploadResult = json.decode(response.body);
      } else {
        final data = json.decode(response.body);
        _errorMessage = data['message'] ?? 'Upload video gagal (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = "Terjadi error: $e";
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAttachments(String noKayuBulat) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _service.fetchAttachments(noKayuBulat);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final data = (decoded['data'] ?? {}) as Map<String, dynamic>;

        final imagesJson = (data['images'] as List?) ?? const [];
        final videosJson = (data['videos'] as List?) ?? const [];

        _imageTiers = imagesJson
            .map((e) => ImageTier.fromJson(e as Map<String, dynamic>))
            .toList();

        _videoTiers = videosJson
            .map((e) => VideoTier.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        final decoded = json.decode(response.body);
        _errorMessage = decoded['message'] ?? 'Gagal load attachments';
      }
    } catch (e) {
      _errorMessage = "Error: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> updateImageMeta({
    required String noKayuBulat,
    required int tier,
    required int pcs,
    String? note,
  }) async {
    _isUploading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _service.updateImageMeta(
        noKayuBulat: noKayuBulat,
        tier: tier,
        pcs: pcs,
        note: note,
      );

      if (response.statusCode == 200) {
        _lastUploadResult = json.decode(response.body);
      } else {
        final data = json.decode(response.body);
        _errorMessage =
            data['message'] ?? 'Update meta gagal (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = "Error: $e";
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }


  Future<void> updateVideoMeta({
    required String noKayuBulat,
    required int noUrut,
    String? remark,
  }) async {
    _isUploading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _service.updateVideoMeta(
        noKayuBulat: noKayuBulat,
        noUrut: noUrut,
        remark: remark,
      );

      if (response.statusCode == 200) {
        _lastUploadResult = json.decode(response.body);
      } else {
        final data = json.decode(response.body);
        _errorMessage =
            data['message'] ?? 'Update video gagal (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = "Error: $e";
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }


  Future<void> deleteImage({
    required String noKayuBulat,
    required int tier,
  }) async {
    _isUploading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _service.deleteImage(
        noKayuBulat: noKayuBulat,
        tier: tier,
      );

      if (response.statusCode == 200) {
        _lastUploadResult = json.decode(response.body);
      } else {
        final data = json.decode(response.body);
        _errorMessage =
            data['message'] ?? 'Delete gagal (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = "Error: $e";
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }


  Future<void> deleteVideo({
    required String noKayuBulat,
    required int noUrut,
  }) async {
    _isUploading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _service.deleteVideo(
        noKayuBulat: noKayuBulat,
        noUrut: noUrut,
      );

      if (response.statusCode == 200) {
        _lastUploadResult = json.decode(response.body);
      } else {
        final data = json.decode(response.body);
        _errorMessage =
            data['message'] ?? 'Gagal hapus video (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = "Error: $e";
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }


}
