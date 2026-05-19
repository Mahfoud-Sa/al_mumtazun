import 'package:equatable/equatable.dart';

import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_query.dart';

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
  final InvoiceQuery query;
  final bool isCreatingInvoice;
  final String? createErrorMessage;
  final bool isUpdatingInvoice;
  final String? updateErrorMessage;
  final int? deletingInvoiceId;
  final String? deleteErrorMessage;

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
    this.query = const InvoiceQuery(),
    this.isCreatingInvoice = false,
    this.createErrorMessage,
    this.isUpdatingInvoice = false,
    this.updateErrorMessage,
    this.deletingInvoiceId,
    this.deleteErrorMessage,
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
    InvoiceQuery? query,
    bool? isCreatingInvoice,
    String? createErrorMessage,
    bool? isUpdatingInvoice,
    String? updateErrorMessage,
    int? deletingInvoiceId,
    String? deleteErrorMessage,
    bool clearError = false,
    bool clearCreateError = false,
    bool clearUpdateError = false,
    bool clearDeletingInvoiceId = false,
    bool clearDeleteError = false,
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
      query: query ?? this.query,
      isCreatingInvoice: isCreatingInvoice ?? this.isCreatingInvoice,
      createErrorMessage: clearCreateError
          ? null
          : createErrorMessage ?? this.createErrorMessage,
      isUpdatingInvoice: isUpdatingInvoice ?? this.isUpdatingInvoice,
      updateErrorMessage: clearUpdateError
          ? null
          : updateErrorMessage ?? this.updateErrorMessage,
      deletingInvoiceId: clearDeletingInvoiceId
          ? null
          : deletingInvoiceId ?? this.deletingInvoiceId,
      deleteErrorMessage: clearDeleteError
          ? null
          : deleteErrorMessage ?? this.deleteErrorMessage,
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
    query,
    isCreatingInvoice,
    createErrorMessage,
    isUpdatingInvoice,
    updateErrorMessage,
    deletingInvoiceId,
    deleteErrorMessage,
  ];
}
