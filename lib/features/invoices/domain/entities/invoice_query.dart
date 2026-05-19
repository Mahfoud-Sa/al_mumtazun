import 'package:equatable/equatable.dart';

class InvoiceQuery extends Equatable {
  final String? search;
  final int? deviceId;
  final int? customerId;
  final DateTime? fromDate;
  final DateTime? toDate;
  final double? minTotal;
  final double? maxTotal;
  final String sortBy;
  final String sortDirection;
  final int page;
  final int size;

  const InvoiceQuery({
    this.search,
    this.deviceId,
    this.customerId,
    this.fromDate,
    this.toDate,
    this.minTotal,
    this.maxTotal,
    this.sortBy = 'date',
    this.sortDirection = 'desc',
    this.page = 1,
    this.size = 10,
  });

  InvoiceQuery copyWith({
    String? search,
    bool clearSearch = false,
    int? deviceId,
    bool clearDeviceId = false,
    int? customerId,
    bool clearCustomerId = false,
    DateTime? fromDate,
    bool clearFromDate = false,
    DateTime? toDate,
    bool clearToDate = false,
    double? minTotal,
    bool clearMinTotal = false,
    double? maxTotal,
    bool clearMaxTotal = false,
    String? sortBy,
    String? sortDirection,
    int? page,
    int? size,
  }) {
    return InvoiceQuery(
      search: clearSearch ? null : search ?? this.search,
      deviceId: clearDeviceId ? null : deviceId ?? this.deviceId,
      customerId: clearCustomerId ? null : customerId ?? this.customerId,
      fromDate: clearFromDate ? null : fromDate ?? this.fromDate,
      toDate: clearToDate ? null : toDate ?? this.toDate,
      minTotal: clearMinTotal ? null : minTotal ?? this.minTotal,
      maxTotal: clearMaxTotal ? null : maxTotal ?? this.maxTotal,
      sortBy: sortBy ?? this.sortBy,
      sortDirection: sortDirection ?? this.sortDirection,
      page: page ?? this.page,
      size: size ?? this.size,
    );
  }

  Map<String, String> toQueryParameters() {
    String dateValue(DateTime value) => value.toUtc().toIso8601String();

    return {
      if (search?.trim().isNotEmpty ?? false) 'search': search!.trim(),
      if (deviceId != null) 'deviceId': deviceId.toString(),
      if (customerId != null) 'customerId': customerId.toString(),
      if (fromDate != null) 'fromDate': dateValue(fromDate!),
      if (toDate != null) 'toDate': dateValue(toDate!),
      if (minTotal != null) 'minTotal': minTotal.toString(),
      if (maxTotal != null) 'maxTotal': maxTotal.toString(),
      'sortBy': sortBy,
      'sortDirection': sortDirection,
      'page': page.toString(),
      'size': size.toString(),
    };
  }

  @override
  List<Object?> get props => [
    search,
    deviceId,
    customerId,
    fromDate,
    toDate,
    minTotal,
    maxTotal,
    sortBy,
    sortDirection,
    page,
    size,
  ];
}
