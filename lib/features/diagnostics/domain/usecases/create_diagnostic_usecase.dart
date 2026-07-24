import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/diagnostic.dart';
import '../repositories/diagnostic_repository.dart';

class CreateDiagnosticUseCase implements UseCase<Diagnostic, Diagnostic> {
  final DiagnosticRepository repository;

  CreateDiagnosticUseCase(this.repository);

  @override
  Future<Either<Failure, Diagnostic>> call(Diagnostic params) {
    return repository.create(params);
  }
}
