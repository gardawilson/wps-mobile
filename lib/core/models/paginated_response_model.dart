// lib/core/models/paginated_response_model.dart
import 'pagination_meta_model.dart';

class PaginatedResponse<T> {
  final List<T> data;
  final PaginationMeta meta;

  const PaginatedResponse({
    required this.data,
    required this.meta,
  });

  factory PaginatedResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonT,
      ) {
    // Jangan pakai List<Map<String,dynamic>>.from(...) karena suka error silent ke-serialize
    final raw = json['data'] as List? ?? const [];

    final list = <T>[];
    for (final e in raw) {
      if (e is Map) {
        // cast aman
        final map = Map<String, dynamic>.from(e as Map);
        list.add(fromJsonT(map));
      } else {
        // kalau ternyata bukan map, SKIP tapi minimal log biar ketahuan
        // (bisa juga dilempar exception kalau mau keras)
        // debugPrint('Unexpected item type: ${e.runtimeType}');
      }
    }

    final meta = PaginationMeta.fromJson(
      (json['meta'] as Map?)?.cast<String, dynamic>() ?? const {},
    );

    return PaginatedResponse<T>(data: list, meta: meta);
  }

  bool get canLoadMore => meta.hasNext;
  int get nextPage => meta.page + 1;
}
