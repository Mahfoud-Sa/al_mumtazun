import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/compound.dart';
import '../../domain/usecases/create_compound_usecase.dart';
import '../../domain/usecases/get_compounds_usecase.dart';
import 'compounds_state.dart';

class CompoundsCubit extends Cubit<CompoundsState> {
  final GetCompoundsUseCase getCompounds;
  final CreateCompoundUseCase createCompound;
  static const int defaultPageSize = 10;

  int _currentPage = 1;
  int _currentSize = defaultPageSize;

  CompoundsCubit({required this.getCompounds, required this.createCompound})
    : super(const CompoundsInitial());

  Future<void> fetch({int? page, int? size}) async {
    final requestedPage = page ?? _currentPage;
    final requestedSize = size ?? _currentSize;

    emit(const CompoundsLoading());
    final result = await getCompounds(
      GetCompoundsParams(page: requestedPage, size: requestedSize),
    );
    result.fold((failure) => emit(CompoundsError(failure.message)), (
      compoundPage,
    ) {
      _currentPage = compoundPage.page;
      _currentSize = compoundPage.size;
      emit(
        CompoundsLoaded(
          compounds: compoundPage.compounds,
          page: compoundPage.page,
          size: compoundPage.size,
          totalCount: compoundPage.totalCount,
          totalPages: compoundPage.totalPages,
        ),
      );
    });
  }

  Future<void> nextPage() async {
    final current = state;
    if (current is! CompoundsLoaded || current.page >= current.totalPages) {
      return;
    }
    await fetch(page: current.page + 1, size: current.size);
  }

  Future<void> previousPage() async {
    final current = state;
    if (current is! CompoundsLoaded || current.page <= 1) return;
    await fetch(page: current.page - 1, size: current.size);
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
}
