import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/income_engineer.dart';
import '../../domain/entities/income_entry.dart';
import '../../domain/repositories/income_repository.dart';
import '../datasources/incomes_remote_datasource.dart';
import '../models/income_entry_model.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  final IncomesRemoteDataSource remote;

  IncomeRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, IncomeEntry>> create(IncomeEntry income) async {
    try {
      final created = await remote.createIncome(
        IncomeEntryModel.fromEntity(income),
      );
      return Right(created);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<IncomeEngineer>>> getEngineers() async {
    try {
      final engineers = await remote.getEngineers();
      return Right(engineers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
