import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/compound.dart';
import '../repositories/compound_repository.dart';

class UpdateCompoundUseCase implements UseCase<Compound, Compound> {
  final CompoundRepository repository;

  UpdateCompoundUseCase(this.repository);

  @override
  Future<Either<Failure, Compound>> call(Compound params) {
    return repository.update(params);
  }
}
