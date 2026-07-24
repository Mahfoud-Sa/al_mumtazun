import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/diagnostic.dart';
import '../../domain/entities/diagnostic_page.dart';
import '../../domain/repositories/diagnostic_repository.dart';
import '../datasources/diagnostics_remote_datasource.dart';
import '../models/diagnostic_model.dart';

class DiagnosticRepositoryImpl implements DiagnosticRepository {
  final DiagnosticsRemoteDataSource remote;

  DiagnosticRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, Diagnostic>> create(Diagnostic diagnostic) async {
    try {
      final created = await remote.createDiagnostic(
        DiagnosticModel.fromEntity(diagnostic),
      );
      return Right(created);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Diagnostic>> update(Diagnostic diagnostic) async {
    try {
      final updated = await remote.updateDiagnostic(
        DiagnosticModel.fromEntity(diagnostic),
      );
      return Right(updated);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> delete(int id) async {
    try {
      await remote.deleteDiagnostic(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final diagnosticPage = await remote.getDiagnostics(
        page: page,
        size: size,
        search: search,
        severity: severity,
        status: status,
        fromDate: fromDate,
        toDate: toDate,
        sortBy: sortBy,
        sortDirection: sortDirection,
      );
      return Right(diagnosticPage);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
