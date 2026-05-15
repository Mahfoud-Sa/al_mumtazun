import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/income_entry.dart';
import '../../domain/usecases/create_income_usecase.dart';
import '../../domain/usecases/get_income_engineers_usecase.dart';
import 'incomes_state.dart';

class IncomesCubit extends Cubit<IncomesState> {
  final CreateIncomeUseCase createIncome;
  final GetIncomeEngineersUseCase getEngineers;

  IncomesCubit({required this.createIncome, required this.getEngineers})
    : super(const IncomesState());

  Future<void> loadEngineers() async {
    emit(
      state.copyWith(
        isLoadingEngineers: true,
        clearError: true,
        submitSucceeded: false,
      ),
    );
    final result = await getEngineers(NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoadingEngineers: false,
          errorMessage: failure.message,
        ),
      ),
      (engineers) => emit(
        state.copyWith(
          engineers: engineers,
          isLoadingEngineers: false,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> submitIncome(IncomeEntry income) async {
    emit(
      state.copyWith(
        isSubmitting: true,
        clearError: true,
        submitSucceeded: false,
      ),
    );
    final result = await createIncome(income);
    result.fold(
      (failure) => emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
          submitSucceeded: false,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isSubmitting: false,
          clearError: true,
          submitSucceeded: true,
        ),
      ),
    );
  }

  void clearSubmitFlag() {
    if (state.submitSucceeded) {
      emit(state.copyWith(submitSucceeded: false));
    }
  }
}
