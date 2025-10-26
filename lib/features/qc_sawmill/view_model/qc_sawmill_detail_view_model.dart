import 'dart:convert' show jsonDecode, jsonEncode, utf8;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/api_constants.dart';
import '../model/qc_sawmill_detail.dart';

class QcSawmillDetailViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String _error = '';
  List<QcSawmillDetail> _items = [];
  String _noQc = '';

  bool get isLoading => _isLoading;
  String get error => _error;
  List<QcSawmillDetail> get items => List.unmodifiable(_items);
  String get noQc => _noQc;

  // ---------- core ----------
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> load(String noQc) async {
    _noQc = noQc;
    _error = '';
    _items = [];
    await _fetch();
  }

  Future<void> refresh() => _fetch();

  Future<void> _fetch() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        _setError('Unauthorized: no token');
        return;
      }

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/api/qc-sawmill/${Uri.encodeComponent(_noQc)}/details',
      );

      _log('[GET] $uri');
      final resp = await http
          .get(uri, headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));

      final bodyStr = utf8.decode(resp.bodyBytes);
      _log('[GET] status=${resp.statusCode} body=$bodyStr');

      if (resp.statusCode == 200) {
        final body = jsonDecode(bodyStr) as Map<String, dynamic>;
        if (body['success'] != true) {
          _setError(body['message']?.toString() ?? 'Gagal memuat detail');
          return;
        }
        final List raw = body['data'] as List? ?? const [];
        _items = raw
            .map((e) => QcSawmillDetail.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();

        // (opsional) normalize setelah fetch kalau server bisa kirim 3,5,7,…
        _items = _normalizeNoUrut(_items);

        _error = '';
      } else if (resp.statusCode == 404) {
        // Anggap sebagai KOSONG (bukan error) supaya UI bisa menampilkan EmptyState
        _items = [];
        _error = '';
        notifyListeners(); // tetap update
      } else if (resp.statusCode == 401) {
        _setError('Unauthorized: Token invalid/expired');
      } else {
        _setError('Server error (${resp.statusCode})');
      }
    } catch (e) {
      _setError('Koneksi/unknown error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------- POST helper (supports overwrite flag) ----------
  Future<bool> _postDetails(List<QcSawmillDetail> items, {required bool overwrite}) async {
    if (_noQc.isEmpty) {
      _setError('NoQc belum di-set. Panggil load(noQc) dulu.');
      return false;
    }

    try {
      final token = await _getToken();
      if (token == null) {
        _setError('Unauthorized: no token');
        return false;
      }

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/api/qc-sawmill/${Uri.encodeComponent(_noQc)}/details',
      );

      final payload = {
        'overwrite': overwrite, // server: replace-all vs append
        'items': items.map((e) => e.toPostMap()).toList(),
      };

      _log('[POST] $uri overwrite=$overwrite items=${items.length}');
      _log('[POST] payload=${jsonEncode(payload)}');

      final resp = await http
          .post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      )
          .timeout(const Duration(seconds: 30));

      final bodyStr = utf8.decode(resp.bodyBytes);
      _log('[POST] status=${resp.statusCode} body=$bodyStr');

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        await _fetch();
        return true;
      }

      final body = _safeBodyMap(resp.bodyBytes);
      _setError(body['message']?.toString() ?? 'Gagal POST (${resp.statusCode})');
      return false;
    } catch (e) {
      _setError('Gagal POST: $e');
      return false;
    }
  }

  // ---------- CREATE / REPLACE-ALL via POST ----------
  /// Replace all rows for current [_noQc] with [items] using POST overwrite=true.
  /// Disini kita **paksa normalisasi 1..N** sebelum kirim.
  Future<bool> replaceAll(List<QcSawmillDetail> items) async {
    final normalized = _normalizeNoUrut(items);
    return _postDetails(normalized, overwrite: true);
  }

  /// Append rows (insert only) using POST overwrite=false.
  /// Disini juga dinormalisasi terhadap urutan gabungan saat ini:
  Future<bool> append(List<QcSawmillDetail> items) async {
    // gabungkan items lama + items baru, lalu normalize → kirim yang BARU dalam bentuk final
    final merged = [..._items, ...items];
    final normalized = _normalizeNoUrut(merged);

    // ambil bagian baru setelah normalisasi (dengan noUrut terbaru)
    final start = _items.length;
    final sliceNew = normalized.sublist(start);

    return _postDetails(sliceNew, overwrite: false);
  }

  // ---------- SAVE (NO PUT/PATCH) ----------
  /// Merge items yang ada dengan drafts lalu replace-all (overwrite=true).
  /// Di sini **noUrut dinormalisasi 1..N** agar server & UI konsisten.
  Future<bool> saveHybrid(List<QcSawmillDetail> drafts) async {
    if (drafts.isEmpty) return true;
    if (_noQc.isEmpty) {
      _setError('NoQc belum di-set. Panggil load(noQc) dulu.');
      return false;
    }

    // Index current items by noUrut
    final byKey = <int, QcSawmillDetail>{};
    for (final e in _items) {
      if (e.noUrut != null) byKey[e.noUrut!] = e;
    }

    // Apply drafts (insert/overwrite). Jika draft ganti key → key baru yang dipakai
    for (final d in drafts) {
      if (d.noUrut == null) {
        _setError('Draft memiliki noUrut null.');
        return false;
      }
      byKey[d.noUrut!] = d;
    }

    // Urutkan berdasarkan noUrut lama dulu…
    final merged = byKey.values.toList()
      ..sort((a, b) => (a.noUrut ?? 0).compareTo(b.noUrut ?? 0));

    _log('[SAVE] merged=${merged.length} sebelum normalize');

    // …lalu NORMALIZE ke 1..N
    final normalized = _normalizeNoUrut(merged);

    _log('[SAVE] replace-all (normalized=${normalized.length})');

    // One POST with overwrite=true -> server replaces the whole grid.
    return await replaceAll(normalized);
  }



  /// Hapus SEMUA detail untuk [_noQc].
  /// Prioritas pakai endpoint DELETE. Jika 404 (route belum ada),
  /// fallback ke POST overwrite=true + items: [].
  Future<bool> deleteAll() async {
    if (_noQc.isEmpty) {
      _setError('NoQc belum di-set. Panggil load(noQc) dulu.');
      return false;
    }

    final token = await _getToken();
    if (token == null) {
      _setError('Unauthorized: no token');
      return false;
    }

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/api/qc-sawmill/${Uri.encodeComponent(_noQc)}/details',
    );

    try {
      _log('[DELETE-ALL] $uri');
      final resp = await http
          .delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      )
          .timeout(const Duration(seconds: 20));

      final bodyStr = utf8.decode(resp.bodyBytes);
      _log('[DELETE-ALL] status=${resp.statusCode} body=$bodyStr');

      // Sukses: 200 OK atau 204 No Content
      if (resp.statusCode == 200 || resp.statusCode == 204) {
        await _fetch();
        return true;
      }

      // Jika route belum ada (mis. 404), fallback ke POST overwrite=true items:[]
      if (resp.statusCode == 404) {
        _log('[DELETE-ALL] route 404, fallback ke POST overwrite=true + items:[]');
        return await _postDetails(const [], overwrite: true);
      }

      final body = _safeBodyMap(resp.bodyBytes);
      _setError(body['message']?.toString() ?? 'Gagal DELETE semua (${resp.statusCode})');
      return false;
    } catch (e) {
      _setError('Gagal DELETE semua: $e');
      return false;
    }
  }

  // ---------- helpers ----------
  /// Normalisasi noUrut: sort by noUrut asc lalu set 1..N.
  /// Menghasilkan list BARU (tidak mutasi argumen).
  List<QcSawmillDetail> _normalizeNoUrut(List<QcSawmillDetail> src) {
    if (src.isEmpty) return const [];

    final sorted = [...src]
      ..sort((a, b) => (a.noUrut ?? 0).compareTo(b.noUrut ?? 0));

    final out = <QcSawmillDetail>[];
    for (var i = 0; i < sorted.length; i++) {
      out.add(_cloneWithNoUrut(sorted[i], i + 1));
    }
    return out;
  }

  /// Utility: clone detail & ganti noUrut
  QcSawmillDetail _cloneWithNoUrut(QcSawmillDetail src, int newNo) {
    return QcSawmillDetail(
      noQc: src.noQc,
      noUrut: newNo,
      noST: src.noST, // jika field masih ada di model
      cuttingTebal: src.cuttingTebal,
      cuttingLebar: src.cuttingLebar,
      actualTebal: src.actualTebal,
      actualLebar: src.actualLebar,
      susutTebal: src.susutTebal,
      susutLebar: src.susutLebar,
    );
    // Jika kamu sudah menghapus noST dari model, hilangkan baris noST di atas.
  }

  /// Beri saran nomor urut berikutnya berdasarkan kondisi _items sekarang.
  int get nextSuggestedNoUrut {
    if (_items.isEmpty) return 1;
    final maxNo = _items.map((e) => e.noUrut ?? 0).fold<int>(0, (p, c) => c > p ? c : p);
    return maxNo + 1;
  }

  Map<String, dynamic> _safeBodyMap(List<int> bytes) {
    try {
      final m = jsonDecode(utf8.decode(bytes));
      return (m is Map<String, dynamic>) ? m : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  void _setError(String msg) {
    _error = msg;
    notifyListeners();
  }

  void _log(String msg) {
    // ignore: avoid_print
    print('[QcSawmillDetailVM] $msg');
  }

}

// Optional: extension can live here OR in the model file (not both).
extension QcSawmillDetailPosting on QcSawmillDetail {
  Map<String, dynamic> toPostMap() {
    return {
      if (noUrut != null) 'noUrut': noUrut,
      if (noST != null && noST!.isNotEmpty) 'noST': noST,
      if (cuttingTebal != null) 'cuttingTebal': cuttingTebal,
      if (cuttingLebar != null) 'cuttingLebar': cuttingLebar,
      if (actualTebal != null) 'actualTebal': actualTebal,
      if (actualLebar != null) 'actualLebar': actualLebar,
      if (susutTebal != null) 'susutTebal': susutTebal,
      if (susutLebar != null) 'susutLebar': susutLebar,
    };
  }
}
