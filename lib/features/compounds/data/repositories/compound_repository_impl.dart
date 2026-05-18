import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/compound.dart';
import '../../domain/entities/compound_page.dart';
import '../../domain/repositories/compound_repository.dart';
import '../datasources/compounds_remote_datasource.dart';
import '../models/compound_model.dart';

class CompoundRepositoryImpl implements CompoundRepository {
  final CompoundsRemoteDataSource remote;

  CompoundRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, Compound>> create(Compound compound) async {
    try {
      final created = await remote.createCompound(
        CompoundModel.fromEntity(compound),
      );
      return Right(created);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Compound>> update(Compound compound) async {
    try {
      final updated = await remote.updateCompound(
        CompoundModel.fromEntity(compound),
      );
      return Right(updated);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> delete(int id) async {
    try {
      await remote.deleteCompound(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CompoundPage>> getAll({
    required int page,
    required int size,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortDirection,
  }) async {
    try {
      final compoundsPage = await remote.getCompounds(
        page: page,
        size: size,
        search: search,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        sortDirection: sortDirection,
      );
      return Right(compoundsPage);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
