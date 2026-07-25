import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/diagnostic.dart';
import '../../domain/usecases/change_diagnostic_status_usecase.dart';
import '../../domain/usecases/create_diagnostic_usecase.dart';
import '../../domain/usecases/delete_diagnostic_usecase.dart';
import '../../domain/usecases/get_diagnostic_by_id_usecase.dart';
import '../../domain/usecases/get_diagnostics_usecase.dart';
import '../../domain/usecases/update_diagnostic_usecase.dart';
import 'diagnostics_state.dart';

class DiagnosticsCubit extends Cubit<DiagnosticsState> {
  final GetDiagnosticsUseCase getDiagnostics;
  final GetDiagnosticByIdUseCase getDiagnosticById;
  final CreateDiagnosticUseCase createDiagnostic;
  final UpdateDiagnosticUseCase updateDiagnostic;
  final ChangeDiagnosticStatusUseCase changeDiagnosticStatusUseCase;
  final DeleteDiagnosticUseCase deleteDiagnostic;
  static const int defaultPageSize = 10;

  int _currentPage = 1;
  int _currentSize = defaultPageSize;
  String? _currentSearch;
  String? _currentSeverity;
  String? _currentStatus;
  DateTime? _currentFromDate;
  DateTime? _currentToDate;
  String _currentSortBy = 'id';
  String _currentSortDirection = 'asc';

  DiagnosticsCubit({
    required this.getDiagnostics,
    required this.getDiagnosticById,
    required this.createDiagnostic,
    required this.updateDiagnostic,
    required this.changeDiagnosticStatusUseCase,
    required this.deleteDiagnostic,
  }) : super(const DiagnosticsInitial());

  Future<void> fetch({
    int? page,
    int? size,
    String? search,
    String? severity,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    String? sortBy,
    String? sortDirection,
    bool append = false,
  }) async {
    final requestedPage = page ?? _currentPage;
    final requestedSize = size ?? _currentSize;
    final requestedSearch = search ?? _currentSearch;
    final requestedSeverity = severity ?? _currentSeverity;
    final requestedStatus = status ?? _currentStatus;
    final requestedFromDate = fromDate ?? _currentFromDate;
    final requestedToDate = toDate ?? _currentToDate;
    final requestedSortBy = sortBy ?? _currentSortBy;
    final requestedSortDirection = sortDirection ?? _currentSortDirection;

    final current = state;
    final currentLoaded = current is DiagnosticsLoaded ? current : null;
    if (append && currentLoaded != null) {
      if (currentLoaded.isLoadingMore ||
          currentLoaded.page >= currentLoaded.totalPages) {
        return;
      }
      emit(currentLoaded.copyWith(isLoadingMore: true));
    } else {
      emit(const DiagnosticsLoading());
    }

    final result = await getDiagnostics(
      GetDiagnosticsParams(
        page: requestedPage,
        size: requestedSize,
        search: requestedSearch,
        severity: requestedSeverity,
        status: requestedStatus,
        fromDate: requestedFromDate,
        toDate: requestedToDate,
        sortBy: requestedSortBy,
        sortDirection: requestedSortDirection,
      ),
    );

    result.fold(
      (failure) {
        if (append && currentLoaded != null) {
          emit(currentLoaded.copyWith(isLoadingMore: false));
        } else {
          emit(DiagnosticsError(failure.message));
        }
      },
      (diagnosticPage) {
        _currentPage = diagnosticPage.page;
        _currentSize = diagnosticPage.size;
        _currentSearch = requestedSearch;
        _currentSeverity = requestedSeverity;
        _currentStatus = requestedStatus;
        _currentFromDate = requestedFromDate;
        _currentToDate = requestedToDate;
        _currentSortBy = requestedSortBy;
        _currentSortDirection = requestedSortDirection;

        final items = append && currentLoaded != null
            ? [...currentLoaded.diagnostics, ...diagnosticPage.diagnostics]
            : diagnosticPage.diagnostics;

        emit(
          DiagnosticsLoaded(
            diagnostics: items,
            page: diagnosticPage.page,
            size: diagnosticPage.size,
            totalCount: diagnosticPage.totalCount,
            totalPages: diagnosticPage.totalPages,
          ),
        );
      },
    );
  }

  Future<void> nextPage() async {
    final current = state;
    if (current is! DiagnosticsLoaded || current.page >= current.totalPages) {
      return;
    }
    await fetch(page: current.page + 1, size: current.size);
  }

  Future<void> loadNextPage() async {
    final current = state;
    if (current is! DiagnosticsLoaded ||
        current.isLoadingMore ||
        current.page >= current.totalPages) {
      return;
    }
    await fetch(page: current.page + 1, size: current.size, append: true);
  }

  Future<void> previousPage() async {
    final current = state;
    if (current is! DiagnosticsLoaded || current.page <= 1) return;
    await fetch(page: current.page - 1, size: current.size);
  }

  Future<void> applyQuery({
    String? search,
    String? severity,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    String sortBy = 'id',
    String sortDirection = 'asc',
  }) async {
    _currentSearch = _blankToNull(search);
    _currentSeverity = _blankToNull(severity);
    _currentStatus = _blankToNull(status);
    _currentFromDate = fromDate;
    _currentToDate = toDate;
    _currentSortBy = sortBy;
    _currentSortDirection = sortDirection;
    await fetch(page: 1, size: _currentSize);
  }

  Future<void> clearQuery() async {
    _currentSearch = null;
    _currentSeverity = null;
    _currentStatus = null;
    _currentFromDate = null;
    _currentToDate = null;
    _currentSortBy = 'id';
    _currentSortDirection = 'asc';
    await fetch(page: 1, size: _currentSize);
  }

  Future<bool> addDiagnostic(Diagnostic diagnostic) async {
    final current = state;
    final currentLoaded = current is DiagnosticsLoaded ? current : null;

    emit(
      DiagnosticsLoaded(
        diagnostics: currentLoaded?.diagnostics ?? <Diagnostic>[],
        page: currentLoaded?.page ?? _currentPage,
        size: currentLoaded?.size ?? _currentSize,
        totalCount: currentLoaded?.totalCount ?? 0,
        totalPages: currentLoaded?.totalPages ?? 1,
        isSubmitting: true,
        isLoadingMore: currentLoaded?.isLoadingMore ?? false,
      ),
    );

    final result = await createDiagnostic(diagnostic);

    return result.fold<Future<bool>>(
      (failure) async {
        emit(DiagnosticsError(failure.message));
        return false;
      },
      (_) async {
        await fetch();
        return true;
      },
    );
  }

  Future<bool> editDiagnostic(Diagnostic diagnostic) async {
    final current = state;
    final currentLoaded = current is DiagnosticsLoaded ? current : null;

    if (currentLoaded != null) {
      emit(currentLoaded.copyWith(isSubmitting: true));
    }

    final result = await updateDiagnostic(diagnostic);

    return result.fold<Future<bool>>(
      (failure) async {
        if (currentLoaded != null) {
          emit(currentLoaded.copyWith(isSubmitting: false));
        } else {
          emit(DiagnosticsError(failure.message));
        }
        return false;
      },
      (_) async {
        await fetch(
          page: currentLoaded?.page ?? _currentPage,
          size: currentLoaded?.size ?? _currentSize,
        );
        return true;
      },
    );
  }

  Future<bool> removeDiagnostic(int id) async {
    final current = state;
    final currentLoaded = current is DiagnosticsLoaded ? current : null;

    if (currentLoaded != null) {
      emit(currentLoaded.copyWith(isSubmitting: true));
    }

    final result = await deleteDiagnostic(id);

    return result.fold<Future<bool>>(
      (failure) async {
        if (currentLoaded != null) {
          emit(currentLoaded.copyWith(isSubmitting: false));
        } else {
          emit(DiagnosticsError(failure.message));
        }
        return false;
      },
      (_) async {
        await fetch(
          page: currentLoaded?.page ?? _currentPage,
          size: currentLoaded?.size ?? _currentSize,
        );
        return true;
      },
    );
  }

  Future<bool> changeDiagnosticStatus(int id, String newStatus) async {
    final current = state;
    final currentLoaded = current is DiagnosticsLoaded ? current : null;

    if (currentLoaded != null) {
      emit(currentLoaded.copyWith(isSubmitting: true));
    }

    final result = await changeDiagnosticStatusUseCase(
      ChangeDiagnosticStatusParams(id: id, status: newStatus),
    );

    return result.fold<Future<bool>>(
      (failure) async {
        if (currentLoaded != null) {
          emit(currentLoaded.copyWith(isSubmitting: false));
        } else {
          emit(DiagnosticsError(failure.message));
        }
        return false;
      },
      (_) async {
        await fetch(
          page: currentLoaded?.page ?? _currentPage,
          size: currentLoaded?.size ?? _currentSize,
        );
        return true;
      },
    );
  }
}

String? _blankToNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}
