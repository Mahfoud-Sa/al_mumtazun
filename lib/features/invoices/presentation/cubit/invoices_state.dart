import 'package:equatable/equatable.dart';

import '../../domain/entities/invoice.dart';

class InvoicesState extends Equatable {
  final List<Invoice> invoices;
  final bool isLoading;
  final bool isLoadingMore;
  final int page;
  final int size;
  final int totalCount;
  final int totalPages;
  final bool hasReachedEnd;
  final String? errorMessage;

  const InvoicesState({
    this.invoices = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.page = 0,
    this.size = 10,
    this.totalCount = 0,
    this.totalPages = 1,
    this.hasReachedEnd = false,
    this.errorMessage,
  });

  InvoicesState copyWith({
    List<Invoice>? invoices,
    bool? isLoading,
    bool? isLoadingMore,
    int? page,
    int? size,
    int? totalCount,
    int? totalPages,
    bool? hasReachedEnd,
    String? errorMessage,
    bool clearError = false,
  }) {
    return InvoicesState(
      invoices: invoices ?? this.invoices,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      page: page ?? this.page,
      size: size ?? this.size,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    invoices,
    isLoading,
    isLoadingMore,
    page,
    size,
    totalCount,
    totalPages,
    hasReachedEnd,
    errorMessage,
  ];
}
