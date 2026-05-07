import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/role.dart';
import '../../domain/repositories/role_repository.dart';
import '../datasources/roles_local_datasource.dart';
import '../models/role_model.dart';

class RoleRepositoryImpl implements RoleRepository {
  final RolesLocalDataSource local;

  RoleRepositoryImpl(this.local);

  @override
  Future<Either<Failure, Role>> create(Role role) async {
    try {
      final roles = await local.getRoles();
      final model = RoleModel(id: role.id, name: role.name, permissions: role.permissions);
      roles.add(model);
      await local.saveRoles(roles);
      return Right(model);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> delete(String id) async {
    try {
      final roles = await local.getRoles();
      roles.removeWhere((r) => r.id == id);
      await local.saveRoles(roles);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Role>>> getAll() async {
    try {
      final roles = await local.getRoles();
      return Right(roles);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Role>> getById(String id) async {
    try {
      final roles = await local.getRoles();
      final r = roles.firstWhere((x) => x.id == id);
      return Right(r);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Role>> update(Role role) async {
    try {
      final roles = await local.getRoles();
      final idx = roles.indexWhere((r) => r.id == role.id);
      final model = RoleModel(id: role.id, name: role.name, permissions: role.permissions);
      if (idx >= 0) roles[idx] = model;
      await local.saveRoles(roles);
      return Right(model);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
