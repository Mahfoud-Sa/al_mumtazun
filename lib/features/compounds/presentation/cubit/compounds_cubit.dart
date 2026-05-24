import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/compound.dart';
import '../../domain/usecases/create_compound_usecase.dart';
import '../../domain/usecases/delete_compound_usecase.dart';
import '../../domain/usecases/get_compounds_usecase.dart';
import '../../domain/usecases/update_compound_usecase.dart';
import 'compounds_state.dart';

class CompoundsCubit extends Cubit<CompoundsState> {
  final GetCompoundsUseCase getCompounds;
  final CreateCompoundUseCase createCompound;
  final UpdateCompoundUseCase updateCompound;
  final DeleteCompoundUseCase deleteCompound;
  static const int defaultPageSize = 10;

  int _currentPage = 1;
  int _currentSize = defaultPageSize;
  String? _currentSearch;
  double? _currentMinPrice;
  double? _currentMaxPrice;
  String _currentSortBy = 'id';
  String _currentSortDirection = 'asc';

  CompoundsCubit({
    required this.getCompounds,
    required this.createCompound,
    required this.updateCompound,
    required this.deleteCompound,
  }) : super(const CompoundsInitial());

  Future<void> fetch({
    int? page,
    int? size,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortDirection,
    bool append = false,
  }) async {
    final requestedPage = page ?? _currentPage;
    final requestedSize = size ?? _currentSize;
    final requestedSearch = search ?? _currentSearch;
    final requestedMinPrice = minPrice ?? _currentMinPrice;
    final requestedMaxPrice = maxPrice ?? _currentMaxPrice;
    final requestedSortBy = sortBy ?? _currentSortBy;
    final requestedSortDirection = sortDirection ?? _currentSortDirection;

    final current = state;
    final currentLoaded = current is CompoundsLoaded ? current : null;
    if (append && currentLoaded != null) {
      if (currentLoaded.isLoadingMore ||
          currentLoaded.page >= currentLoaded.totalPages) {
        return;
      }
      emit(currentLoaded.copyWith(isLoadingMore: true));
    } else {
      emit(const CompoundsLoading());
    }

    final result = await getCompounds(
      GetCompoundsParams(
        page: requestedPage,
        size: requestedSize,
        search: requestedSearch,
        minPrice: requestedMinPrice,
        maxPrice: requestedMaxPrice,
        sortBy: requestedSortBy,
        sortDirection: requestedSortDirection,
      ),
    );
    result.fold(
      (failure) {
        if (append && currentLoaded != null) {
          emit(currentLoaded.copyWith(isLoadingMore: false));
        } else {
          emit(CompoundsError(failure.message));
        }
      },
      (compoundPage) {
        _currentPage = compoundPage.page;
        _currentSize = compoundPage.size;
        _currentSearch = requestedSearch;
        _currentMinPrice = requestedMinPrice;
        _currentMaxPrice = requestedMaxPrice;
        _currentSortBy = requestedSortBy;
        _currentSortDirection = requestedSortDirection;
        final compounds = append && currentLoaded != null
            ? [...currentLoaded.compounds, ...compoundPage.compounds]
            : compoundPage.compounds;
        emit(
          CompoundsLoaded(
            compounds: compounds,
            page: compoundPage.page,
            size: compoundPage.size,
            totalCount: compoundPage.totalCount,
            totalPages: compoundPage.totalPages,
          ),
        );
      },
    );
  }

  Future<void> nextPage() async {
    final current = state;
    if (current is! CompoundsLoaded || current.page >= current.totalPages) {
      return;
    }
    await fetch(page: current.page + 1, size: current.size);
  }

  Future<void> loadNextPage() async {
    final current = state;
    if (current is! CompoundsLoaded ||
        current.isLoadingMore ||
        current.page >= current.totalPages) {
      return;
    }
    await fetch(page: current.page + 1, size: current.size, append: true);
  }

  Future<void> previousPage() async {
    final current = state;
    if (current is! CompoundsLoaded || current.page <= 1) return;
    await fetch(page: current.page - 1, size: current.size);
  }

  Future<void> applyQuery({
    String? search,
    double? minPrice,
    double? maxPrice,
    String sortBy = 'id',
    String sortDirection = 'asc',
  }) async {
    _currentSearch = _blankToNull(search);
    _currentMinPrice = minPrice;
    _currentMaxPrice = maxPrice;
    _currentSortBy = sortBy;
    _currentSortDirection = sortDirection;
    await fetch(page: 1, size: _currentSize);
  }

  Future<void> clearQuery() async {
    _currentSearch = null;
    _currentMinPrice = null;
    _currentMaxPrice = null;
    _currentSortBy = 'id';
    _currentSortDirection = 'asc';
    await fetch(page: 1, size: _currentSize);
  }

  Future<bool> addCompound(Compound compound) async {
    final current = state;
    final currentLoaded = current is CompoundsLoaded ? current : null;

    emit(
      CompoundsLoaded(
        compounds: currentLoaded?.compounds ?? <Compound>[],
        page: currentLoaded?.page ?? _currentPage,
        size: currentLoaded?.size ?? _currentSize,
        totalCount: currentLoaded?.totalCount ?? 0,
        totalPages: currentLoaded?.totalPages ?? 1,
        isSubmitting: true,
        isLoadingMore: currentLoaded?.isLoadingMore ?? false,
      ),
    );
    final result = await createCompound(compound);

    return result.fold<Future<bool>>(
      (failure) async {
        emit(CompoundsError(failure.message));
        return false;
      },
      (_) async {
        await fetch();
        return true;
      },
    );
  }

  Future<bool> editCompound(Compound compound) async {
    final current = state;
    final currentLoaded = current is CompoundsLoaded ? current : null;

    if (currentLoaded != null) {
      emit(currentLoaded.copyWith(isSubmitting: true));
    }

    final result = await updateCompound(compound);
    return result.fold<Future<bool>>(
      (failure) async {
        if (currentLoaded != null) {
          emit(currentLoaded.copyWith(isSubmitting: false));
        } else {
          emit(CompoundsError(failure.message));
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

  Future<bool> removeCompound(int id) async {
    final current = state;
    final currentLoaded = current is CompoundsLoaded ? current : null;

    if (currentLoaded != null) {
      emit(currentLoaded.copyWith(isSubmitting: true));
    }

    final result = await deleteCompound(id);
    return result.fold<Future<bool>>(
      (failure) async {
        if (currentLoaded != null) {
          emit(currentLoaded.copyWith(isSubmitting: false));
        } else {
          emit(CompoundsError(failure.message));
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
