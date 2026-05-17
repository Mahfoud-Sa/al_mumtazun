import 'package:equatable/equatable.dart';

import 'invoice.dart';

class InvoicePage extends Equatable {
  final List<Invoice> invoices;
  final int page;
  final int size;
  final int totalCount;
  final int totalPages;

  const InvoicePage({
    required this.invoices,
    required this.page,
    required this.size,
    required this.totalCount,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [invoices, page, size, totalCount, totalPages];
}
