// services/kayu_bulat_service.dart
import 'dart:convert'; // <-- tambahin ini
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // penting untuk contentType
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/api_constants.dart';

class KayuBulatService {
  /// Ambil token dari SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// GET attachments (images + videos)
  Future<http.Response> fetchAttachments(String noKayuBulat) async {
    final token = await _getToken();
    if (token == null) throw Exception("Token not found");

    final url = Uri.parse(
        "${ApiConstants.baseUrl}/api/kayu-bulat/$noKayuBulat/attachments");

    return await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );
  }

  /// Upload image → field name = "image"
  Future<http.Response> uploadImage({
    required String noKayuBulat,
    required File file,
    required int tier,
    required int pcs,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception("Token not found");

    final url = Uri.parse(
        "${ApiConstants.baseUrl}/api/kayu-bulat/$noKayuBulat/upload-image");

    final req = http.MultipartRequest("POST", url)
      ..headers["Authorization"] = "Bearer $token"
      ..fields["tier"] = tier.toString()
      ..fields["pcs"] = pcs.toString()
      ..files.add(await http.MultipartFile.fromPath(
        "image", // harus sama dengan controller backend
        file.path,
        contentType: MediaType("image", "jpeg"), // fallback, biar aman
      ));

    final streamed = await req.send();
    return http.Response.fromStream(streamed);
  }

  /// Upload video → field name = "video"
  Future<http.Response> uploadVideo({
    required String noKayuBulat,
    required File file,
    required int noUrut,
    String? remark,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception("Token not found");

    final url = Uri.parse(
        "${ApiConstants.baseUrl}/api/kayu-bulat/$noKayuBulat/upload-video");

    // Tentukan subtype video berdasarkan ekstensi file
    String _videoSubtypeFromPath(String path) {
      final lower = path.toLowerCase();
      if (lower.endsWith(".mp4")) return "mp4";
      if (lower.endsWith(".mov")) return "quicktime";
      if (lower.endsWith(".avi")) return "x-msvideo";
      if (lower.endsWith(".mkv")) return "x-matroska";
      return "mp4";
    }

    final req = http.MultipartRequest("POST", url)
      ..headers["Authorization"] = "Bearer $token"
      ..fields["noUrut"] = noUrut.toString();

    if (remark != null && remark.isNotEmpty) {
      req.fields["remark"] = remark;
    }

    req.files.add(await http.MultipartFile.fromPath(
      "video", // sesuai controller backend
      file.path,
      contentType: MediaType("video", _videoSubtypeFromPath(file.path)),
    ));

    final streamed = await req.send();
    return http.Response.fromStream(streamed);
  }


  /// Update PCS & Note tanpa upload file (IMAGE)
  Future<http.Response> updateImageMeta({
    required String noKayuBulat,
    required int tier,
    required int pcs,
    String? note,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception("Token not found");

    final url = Uri.parse(
      "${ApiConstants.baseUrl}/api/kayu-bulat/$noKayuBulat/update-image",
    );

    final body = {
      "tier": tier.toString(),
      "pcs": pcs.toString(),
    };
    if (note != null && note.isNotEmpty) {
      body["note"] = note;
    }

    return await http.put(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
  }

  /// Update remark tanpa upload file (VIDEO)
  Future<http.Response> updateVideoMeta({
    required String noKayuBulat,
    required int noUrut,
    String? remark,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception("Token not found");

    final url = Uri.parse(
      "${ApiConstants.baseUrl}/api/kayu-bulat/$noKayuBulat/update-video",
    );

    final body = {
      "noUrut": noUrut.toString(),
    };
    if (remark != null && remark.isNotEmpty) {
      body["remark"] = remark;
    }

    return await http.put(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
  }

  /// Delete image by tier
  Future<http.Response> deleteImage({
    required String noKayuBulat,
    required int tier,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception("Token not found");

    final url = Uri.parse(
      "${ApiConstants.baseUrl}/api/kayu-bulat/$noKayuBulat/delete-image/$tier",
    );

    return await http.delete(
      url,
      headers: {"Authorization": "Bearer $token"},
    );
  }


  /// Delete video by noUrut
  Future<http.Response> deleteVideo({
    required String noKayuBulat,
    required int noUrut,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception("Token not found");

    final url = Uri.parse(
      "${ApiConstants.baseUrl}/api/kayu-bulat/$noKayuBulat/delete-video/$noUrut",
    );

    return await http.delete(
      url,
      headers: {"Authorization": "Bearer $token"},
    );
  }



}
