// lib/core/network/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants/api_constants.dart';
import '../auth/token_provider.dart';

class ApiClient {
  final TokenProvider tokenProvider;
  final http.Client _client;

  ApiClient({required this.tokenProvider, http.Client? client})
      : _client = client ?? http.Client();

  /// Header default dengan Bearer token (jika ada).
  Future<Map<String, String>> _headers([Map<String, String>? extra]) async {
    final token = await tokenProvider.getToken();
    final base = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    if (extra != null) base.addAll(extra);
    return base;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    return Uri.parse('${ApiConstants.baseUrl}$path').replace(queryParameters: {
      if (query != null) ...query.map((k, v) => MapEntry(k, '$v')),
    });
  }

  // ---- Metode HTTP ringkas ----
  Future<http.Response> get(String path, {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    return _client.get(_uri(path, query), headers: await _headers(headers));
  }

  Future<http.Response> post(String path, {Object? body, Map<String, String>? headers}) async {
    return _client.post(_uri(path), headers: await _headers(headers), body: body is String ? body : jsonEncode(body ?? {}));
  }

  Future<http.Response> put(String path, {Object? body, Map<String, String>? headers}) async {
    return _client.put(_uri(path), headers: await _headers(headers), body: body is String ? body : jsonEncode(body ?? {}));
  }

  Future<http.Response> delete(String path, {Object? body, Map<String, String>? headers}) async {
    return _client.delete(_uri(path), headers: await _headers(headers), body: body is String ? body : jsonEncode(body ?? {}));
  }

  // Utility bantu decode + cek sukses (opsional)
  Map<String, dynamic> decodeOrThrow(http.Response resp) {
    final text = utf8.decode(resp.bodyBytes);
    try {
      return jsonDecode(text) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Server error (${resp.statusCode})');
    }
  }
}
