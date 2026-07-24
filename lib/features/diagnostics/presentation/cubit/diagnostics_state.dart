import 'package:equatable/equatable.dart';

import '../../domain/entities/diagnostic.dart';

abstract class DiagnosticsState extends Equatable {
  const DiagnosticsState();

  @override
  List<Object?> get props => [];
}

class DiagnosticsInitial extends DiagnosticsState {
  const DiagnosticsInitial();
}

class DiagnosticsLoading extends DiagnosticsState {
  const DiagnosticsLoading();
}

class DiagnosticsLoaded extends DiagnosticsState {
  final List<Diagnostic> diagnostics;
  final int page;
  final int size;
  final int totalCount;
  final int totalPages;
  final bool isSubmitting;
  final bool isLoadingMore;

  const DiagnosticsLoaded({
    required this.diagnostics,
    required this.page,
    required this.size,
    required this.totalCount,
    required this.totalPages,
    this.isSubmitting = false,
    this.isLoadingMore = false,
  });

  DiagnosticsLoaded copyWith({
    List<Diagnostic>? diagnostics,
    int? page,
    int? size,
    int? totalCount,
    int? totalPages,
    bool? isSubmitting,
    bool? isLoadingMore,
  }) {
    return DiagnosticsLoaded(
      diagnostics: diagnostics ?? this.diagnostics,
      page: page ?? this.page,
      size: size ?? this.size,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        diagnostics,
        page,
        size,
        totalCount,
        totalPages,
        isSubmitting,
        isLoadingMore,
      ];
}

class DiagnosticsError extends DiagnosticsState {
  final String message;

  const DiagnosticsError(this.message);

  @override
  List<Object?> get props => [message];
}
