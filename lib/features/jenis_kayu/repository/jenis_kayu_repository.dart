// lib/features/jenis_kayu/repository/jenis_kayu_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/network/api_client.dart';
import '../model/jenis_kayu_model.dart';

class JenisKayuRepository {
  final ApiClient api;

  JenisKayuRepository(this.api);

  List<JenisKayu>? _cache;
  DateTime? _cacheAt;
  final Duration _ttl = const Duration(minutes: 10);

  Future<List<JenisKayu>> getAllEnabled({bool force = false}) async {
    final now = DateTime.now();
    if (!force && _cache != null && _cacheAt != null && now.difference(_cacheAt!) < _ttl) {
      return _cache!;
    }

    final http.Response resp = await api.get('/api/jenis-kayu');
    if (resp.statusCode != 200) {
      final map = api.decodeOrThrow(resp);
      throw Exception(map['message'] ?? 'Server error (${resp.statusCode})');
    }

    final map = api.decodeOrThrow(resp);
    if (map['success'] != true) {
      throw Exception(map['message'] ?? 'Gagal memuat jenis kayu');
    }

    final List data = (map['data'] as List? ?? const []);
    final list = data.map((e) => JenisKayu.fromJson(e as Map<String, dynamic>)).toList()
      ..sort((a, b) => a.jenis.toLowerCase().compareTo(b.jenis.toLowerCase()));

    _cache = list;
    _cacheAt = now;
    return list;
  }
}
