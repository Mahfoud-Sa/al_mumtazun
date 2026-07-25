import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/diagnostic.dart';
import '../repositories/diagnostic_repository.dart';

class ChangeDiagnosticStatusParams {
  final int id;
  final String status;

  const ChangeDiagnosticStatusParams({
    required this.id,
    required this.status,
  });
}

class ChangeDiagnosticStatusUseCase
    implements UseCase<Diagnostic, ChangeDiagnosticStatusParams> {
  final DiagnosticRepository repository;

  ChangeDiagnosticStatusUseCase(this.repository);

  @override
  Future<Either<Failure, Diagnostic>> call(ChangeDiagnosticStatusParams params) {
    return repository.changeStatus(params.id, params.status);
  }
}
