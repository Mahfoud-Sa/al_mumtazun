import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/diagnostic.dart';
import '../repositories/diagnostic_repository.dart';

class GetDiagnosticByIdUseCase implements UseCase<Diagnostic, int> {
  final DiagnosticRepository repository;

  GetDiagnosticByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Diagnostic>> call(int id) {
    return repository.getById(id);
  }
}
