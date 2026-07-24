import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/diagnostic_page.dart';
import '../repositories/diagnostic_repository.dart';

class GetDiagnosticsUseCase implements UseCase<DiagnosticPage, GetDiagnosticsParams> {
  final DiagnosticRepository repository;

  GetDiagnosticsUseCase(this.repository);

  @override
  Future<Either<Failure, DiagnosticPage>> call(GetDiagnosticsParams params) {
    return repository.getAll(
      page: params.page,
      size: params.size,
      search: params.search,
      severity: params.severity,
      status: params.status,
      fromDate: params.fromDate,
      toDate: params.toDate,
      sortBy: params.sortBy,
      sortDirection: params.sortDirection,
    );
  }
}

class GetDiagnosticsParams {
  final int page;
  final int size;
  final String? search;
  final String? severity;
  final String? status;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? sortBy;
  final String? sortDirection;

  const GetDiagnosticsParams({
    required this.page,
    required this.size,
    this.search,
    this.severity,
    this.status,
    this.fromDate,
    this.toDate,
    this.sortBy,
    this.sortDirection,
  });
}
