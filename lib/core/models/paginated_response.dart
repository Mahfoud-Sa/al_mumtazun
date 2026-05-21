class PaginatedResponse<T> {
  final int page;
  final int size;
  final int totalCount;
  final int totalPages;
  final List<T> data;

  const PaginatedResponse({
    required this.page,
    required this.size,
    required this.totalCount,
    required this.totalPages,
    required this.data,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final rawData = json['data'];
    final data = rawData is List
        ? rawData
              .whereType<Map<String, dynamic>>()
              .map(fromJson)
              .toList(growable: false)
        : <T>[];

    return PaginatedResponse<T>(
      page: _readInt(json['page'], 1),
      size: _readInt(json['size'], data.length),
      totalCount: _readInt(json['totalCount'], data.length),
      totalPages: _readInt(json['totalPages'], 1).clamp(1, 999999),
      data: data,
    );
  }

  static int _readInt(dynamic value, int fallback) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
