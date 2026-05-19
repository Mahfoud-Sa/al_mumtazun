import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_query.dart';
import '../../domain/usecases/create_invoice_usecase.dart';
import '../../domain/usecases/delete_invoice_usecase.dart';
import '../../domain/usecases/get_invoices_usecase.dart';
import '../../domain/usecases/update_invoice_usecase.dart';
import 'invoices_state.dart';

class InvoicesCubit extends Cubit<InvoicesState> {
  final GetInvoicesUseCase getInvoices;
  final CreateInvoiceUseCase createInvoice;
  final UpdateInvoiceUseCase updateInvoice;
  final DeleteInvoiceUseCase deleteInvoice;
  static const int defaultPageSize = 10;

  InvoicesCubit({
    required this.getInvoices,
    required this.createInvoice,
    required this.updateInvoice,
    required this.deleteInvoice,
  }) : super(const InvoicesState());

  Future<void> fetch({bool refresh = false}) async {
    if (state.isLoading || state.isLoadingMore) return;
    if (!refresh && state.hasReachedEnd) return;

    emit(
      state.copyWith(
        isLoading: refresh || state.invoices.isEmpty,
        isLoadingMore: !refresh && state.invoices.isNotEmpty,
        page: refresh ? 0 : state.page,
        hasReachedEnd: refresh ? false : state.hasReachedEnd,
        clearError: true,
      ),
    );

    final requestedPage = refresh || state.page == 0 ? 1 : state.page + 1;
    final query = state.query.copyWith(
      page: requestedPage,
      size: state.query.size == 0 ? defaultPageSize : state.query.size,
    );
    final result = await getInvoices(GetInvoicesParams(query: query));

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          errorMessage: failure.message,
        ),
      ),
      (invoicePage) {
        final invoices = refresh || state.page == 0
            ? invoicePage.invoices
            : [...state.invoices, ...invoicePage.invoices];
        emit(
          state.copyWith(
            invoices: invoices,
            isLoading: false,
            isLoadingMore: false,
            page: invoicePage.page,
            size: invoicePage.size,
            query: query.copyWith(
              page: invoicePage.page,
              size: invoicePage.size,
            ),
            totalCount: invoicePage.totalCount,
            totalPages: invoicePage.totalPages,
            hasReachedEnd:
                invoicePage.page >= invoicePage.totalPages ||
                invoicePage.invoices.length < invoicePage.size,
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> updateSearch(String value) {
    return _applyQuery(
      state.query.copyWith(
        search: value.trim().isEmpty ? null : value,
        clearSearch: value.trim().isEmpty,
      ),
    );
  }

  Future<void> updateFilters({
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
    int? size,
  }) {
    return _applyQuery(
      state.query.copyWith(
        search: search,
        clearSearch: clearSearch,
        deviceId: deviceId,
        clearDeviceId: clearDeviceId,
        customerId: customerId,
        clearCustomerId: clearCustomerId,
        fromDate: fromDate,
        clearFromDate: clearFromDate,
        toDate: toDate,
        clearToDate: clearToDate,
        minTotal: minTotal,
        clearMinTotal: clearMinTotal,
        maxTotal: maxTotal,
        clearMaxTotal: clearMaxTotal,
        sortBy: sortBy,
        sortDirection: sortDirection,
        size: size,
      ),
    );
  }

  Future<void> updateSorting(String sortBy, String sortDirection) {
    return _applyQuery(
      state.query.copyWith(sortBy: sortBy, sortDirection: sortDirection),
    );
  }

  Future<void> clearFilters() {
    return _applyQuery(
      InvoiceQuery(
        search: state.query.search,
        sortBy: state.query.sortBy,
        sortDirection: state.query.sortDirection,
        size: state.query.size,
      ),
    );
  }

  Future<void> resetQuery() => _applyQuery(const InvoiceQuery());

  Future<void> goToPage(int page) {
    final target = page.clamp(1, state.totalPages);
    emit(
      state.copyWith(
        invoices: const [],
        page: 0,
        hasReachedEnd: false,
        query: state.query.copyWith(page: target),
        clearError: true,
      ),
    );
    return _fetchExactPage(target);
  }

  Future<void> _applyQuery(InvoiceQuery query) {
    emit(
      state.copyWith(
        invoices: const [],
        page: 0,
        totalCount: 0,
        totalPages: 1,
        hasReachedEnd: false,
        query: query.copyWith(page: 1),
        clearError: true,
      ),
    );
    return fetch(refresh: true);
  }

  Future<void> _fetchExactPage(int page) async {
    if (state.isLoading || state.isLoadingMore) return;

    final query = state.query.copyWith(page: page);
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await getInvoices(GetInvoicesParams(query: query));

    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (invoicePage) => emit(
        state.copyWith(
          invoices: invoicePage.invoices,
          isLoading: false,
          page: invoicePage.page,
          size: invoicePage.size,
          totalCount: invoicePage.totalCount,
          totalPages: invoicePage.totalPages,
          query: query.copyWith(page: invoicePage.page, size: invoicePage.size),
          hasReachedEnd: invoicePage.page >= invoicePage.totalPages,
          clearError: true,
        ),
      ),
    );
  }

  Future<bool> addInvoice(Invoice invoice) async {
    if (state.isCreatingInvoice) return false;

    emit(state.copyWith(isCreatingInvoice: true, clearCreateError: true));
    final result = await createInvoice(CreateInvoiceParams(invoice: invoice));

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            isCreatingInvoice: false,
            createErrorMessage: failure.message,
          ),
        );
        return false;
      },
      (_) {
        emit(state.copyWith(isCreatingInvoice: false, clearCreateError: true));
        return true;
      },
    );
  }

  Future<bool> updateExistingInvoice({
    required int id,
    required Invoice invoice,
  }) async {
    if (state.isUpdatingInvoice) return false;

    emit(state.copyWith(isUpdatingInvoice: true, clearUpdateError: true));
    final result = await updateInvoice(
      UpdateInvoiceParams(id: id, invoice: invoice),
    );

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            isUpdatingInvoice: false,
            updateErrorMessage: failure.message,
          ),
        );
        return false;
      },
      (updated) {
        final invoices = state.invoices
            .map((invoice) => invoice.id == id ? updated : invoice)
            .toList();
        emit(
          state.copyWith(
            invoices: invoices,
            isUpdatingInvoice: false,
            clearUpdateError: true,
          ),
        );
        return true;
      },
    );
  }

  Future<bool> deleteExistingInvoice(int id) async {
    if (state.deletingInvoiceId != null) return false;

    emit(
      state.copyWith(
        deletingInvoiceId: id,
        clearDeleteError: true,
        clearDeletingInvoiceId: false,
      ),
    );
    final result = await deleteInvoice(DeleteInvoiceParams(id: id));

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            deleteErrorMessage: failure.message,
            clearDeletingInvoiceId: true,
          ),
        );
        return false;
      },
      (_) {
        final invoices = state.invoices
            .where((invoice) => invoice.id != id)
            .toList();
        emit(
          state.copyWith(
            invoices: invoices,
            totalCount: state.totalCount > 0
                ? state.totalCount - 1
                : state.totalCount,
            clearDeleteError: true,
            clearDeletingInvoiceId: true,
          ),
        );
        return true;
      },
    );
  }
}
