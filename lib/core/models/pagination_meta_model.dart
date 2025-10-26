// lib/common/models/pagination_model.dart
class PaginationMeta {
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;
  final bool hasPrev;
  final bool hasNext;

  const PaginationMeta({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
    required this.hasPrev,
    required this.hasNext,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> j) => PaginationMeta(
    page: j['page'] ?? 1,
    pageSize: j['pageSize'] ?? 20,
    total: j['total'] ?? 0,
    totalPages: j['totalPages'] ?? 1,
    hasPrev: j['hasPrev'] ?? false,
    hasNext: j['hasNext'] ?? false,
  );
}
