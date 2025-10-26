import '../../../core/network/api_client.dart';
import '../model/mesin_sawmill_model.dart';

class MesinSawmillRepository {
  final ApiClient api;
  MesinSawmillRepository(this.api);

  List<MesinSawmill>? _cache;
  DateTime? _cacheAt;
  final Duration _ttl = const Duration(minutes: 10);

  Future<List<MesinSawmill>> getAllEnabled({bool force = false}) async {
    final now = DateTime.now();
    if (!force && _cache != null && _cacheAt != null && now.difference(_cacheAt!) < _ttl) {
      return _cache!;
    }

    final resp = await api.get('/api/mesin-sawmill');
    if (resp.statusCode != 200) {
      final map = api.decodeOrThrow(resp);
      throw Exception(map['message'] ?? 'Server error (${resp.statusCode})');
    }

    final map = api.decodeOrThrow(resp);
    if (map['success'] != true) {
      throw Exception(map['message'] ?? 'Gagal memuat mesin sawmill');
    }

    final List data = (map['data'] as List? ?? const []);
    final list = data
        .map((e) => MesinSawmill.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.namaMeja.toLowerCase().compareTo(b.namaMeja.toLowerCase()));

    _cache = list;
    _cacheAt = now;
    return list;
  }
}
