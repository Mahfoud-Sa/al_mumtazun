import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/compound.dart';
import '../entities/compound_page.dart';

abstract class CompoundRepository {
  Future<Either<Failure, CompoundPage>> getAll({
    required int page,
    required int size,
  });
  Future<Either<Failure, Compound>> create(Compound compound);
  Future<Either<Failure, Compound>> update(Compound compound);
  Future<Either<Failure, void>> delete(int id);
}
