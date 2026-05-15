import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/income_engineer.dart';
import '../repositories/income_repository.dart';

class GetIncomeEngineersUseCase
    implements UseCase<List<IncomeEngineer>, NoParams> {
  final IncomeRepository repository;

  GetIncomeEngineersUseCase(this.repository);

  @override
  Future<Either<Failure, List<IncomeEngineer>>> call(NoParams params) {
    return repository.getEngineers();
  }
}
