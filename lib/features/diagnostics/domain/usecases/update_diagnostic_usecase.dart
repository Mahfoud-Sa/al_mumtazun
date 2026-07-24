import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/diagnostic.dart';
import '../repositories/diagnostic_repository.dart';

class UpdateDiagnosticUseCase implements UseCase<Diagnostic, Diagnostic> {
  final DiagnosticRepository repository;

  UpdateDiagnosticUseCase(this.repository);

  @override
  Future<Either<Failure, Diagnostic>> call(Diagnostic params) {
    return repository.update(params);
  }
}
