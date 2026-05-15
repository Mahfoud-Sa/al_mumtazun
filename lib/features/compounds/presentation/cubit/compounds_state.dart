import 'package:equatable/equatable.dart';

import '../../domain/entities/compound.dart';

abstract class CompoundsState extends Equatable {
  const CompoundsState();

  @override
  List<Object?> get props => [];
}

class CompoundsInitial extends CompoundsState {
  const CompoundsInitial();
}

class CompoundsLoading extends CompoundsState {
  const CompoundsLoading();
}

class CompoundsLoaded extends CompoundsState {
  final List<Compound> compounds;
  final int page;
  final int size;
  final int totalCount;
  final int totalPages;
  final bool isSubmitting;

  const CompoundsLoaded({
    required this.compounds,
    required this.page,
    required this.size,
    required this.totalCount,
    required this.totalPages,
    this.isSubmitting = false,
  });

  @override
  List<Object?> get props => [
    compounds,
    page,
    size,
    totalCount,
    totalPages,
    isSubmitting,
  ];
}

class CompoundsError extends CompoundsState {
  final String message;

  const CompoundsError(this.message);

  @override
  List<Object?> get props => [message];
}
