import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_invoices_usecase.dart';
import 'invoices_state.dart';

class InvoicesCubit extends Cubit<InvoicesState> {
  final GetInvoicesUseCase getInvoices;
  static const int defaultPageSize = 10;

  InvoicesCubit({required this.getInvoices}) : super(const InvoicesState());

  Future<void> fetch({bool refresh = false}) async {
    if (state.isLoading || state.isLoadingMore) return;

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
    final result = await getInvoices(
      GetInvoicesParams(
        page: requestedPage,
        size: state.size == 0 ? defaultPageSize : state.size,
      ),
    );

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
}
