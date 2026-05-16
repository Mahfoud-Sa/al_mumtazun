import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/compound_repository.dart';

class DeleteCompoundUseCase implements UseCase<void, int> {
  final CompoundRepository repository;

  DeleteCompoundUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(int params) {
    return repository.delete(params);
  }
}
