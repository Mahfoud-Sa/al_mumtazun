import 'package:equatable/equatable.dart';

import '../../domain/entities/income_engineer.dart';

class IncomesState extends Equatable {
  final List<IncomeEngineer> engineers;
  final bool isLoadingEngineers;
  final bool isSubmitting;
  final String? errorMessage;
  final bool submitSucceeded;

  const IncomesState({
    this.engineers = const [],
    this.isLoadingEngineers = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.submitSucceeded = false,
  });

  IncomesState copyWith({
    List<IncomeEngineer>? engineers,
    bool? isLoadingEngineers,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    bool? submitSucceeded,
  }) {
    return IncomesState(
      engineers: engineers ?? this.engineers,
      isLoadingEngineers: isLoadingEngineers ?? this.isLoadingEngineers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      submitSucceeded: submitSucceeded ?? this.submitSucceeded,
    );
  }

  @override
  List<Object?> get props => [
    engineers,
    isLoadingEngineers,
    isSubmitting,
    errorMessage,
    submitSucceeded,
  ];
}
