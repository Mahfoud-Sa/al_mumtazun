import 'package:equatable/equatable.dart';

import 'diagnostic.dart';

class DiagnosticPage extends Equatable {
  final List<Diagnostic> diagnostics;
  final int page;
  final int size;
  final int totalCount;
  final int totalPages;

  const DiagnosticPage({
    required this.diagnostics,
    required this.page,
    required this.size,
    required this.totalCount,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [diagnostics, page, size, totalCount, totalPages];
}
