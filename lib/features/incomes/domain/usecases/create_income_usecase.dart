import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/income_entry.dart';
import '../repositories/income_repository.dart';

class CreateIncomeUseCase implements UseCase<IncomeEntry, IncomeEntry> {
  final IncomeRepository repository;

  CreateIncomeUseCase(this.repository);

  @override
  Future<Either<Failure, IncomeEntry>> call(IncomeEntry params) {
    return repository.create(params);
  }
}
