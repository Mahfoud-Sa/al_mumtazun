import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/income_engineer.dart';
import '../entities/income_entry.dart';

abstract class IncomeRepository {
  Future<Either<Failure, IncomeEntry>> create(IncomeEntry income);
  Future<Either<Failure, List<IncomeEngineer>>> getEngineers();
}
