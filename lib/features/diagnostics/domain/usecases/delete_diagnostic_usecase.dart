import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/diagnostic_repository.dart';

class DeleteDiagnosticUseCase implements UseCase<void, int> {
  final DiagnosticRepository repository;

  DeleteDiagnosticUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(int params) {
    return repository.delete(params);
  }
}
