import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/diagnostic.dart';
import '../entities/diagnostic_page.dart';

abstract class DiagnosticRepository {
  Future<Either<Failure, DiagnosticPage>> getAll({
    required int page,
    required int size,
    String? search,
    String? severity,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    String? sortBy,
    String? sortDirection,
  });
  Future<Either<Failure, Diagnostic>> create(Diagnostic diagnostic);
  Future<Either<Failure, Diagnostic>> update(Diagnostic diagnostic);
  Future<Either<Failure, void>> delete(int id);
}
