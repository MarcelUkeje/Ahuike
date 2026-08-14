class PageMeta {
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;

  const PageMeta({
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  factory PageMeta.fromJson(Map<String, dynamic> json) {
    return PageMeta(
      total:   json['total']   as int,
      limit:   json['limit']   as int,
      offset:  json['offset']  as int,
      hasMore: json['hasMore'] as bool,
    );
  }

  static const empty = PageMeta(total: 0, limit: 20, offset: 0, hasMore: false);
}

class PagedResponse<T> {
  final List<T> items;
  final PageMeta meta;

  const PagedResponse({required this.items, required this.meta});
}
