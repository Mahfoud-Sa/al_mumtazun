import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/role.dart';

abstract class RoleRepository {
  Future<Either<Failure, Role>> create(Role role);
  Future<Either<Failure, List<Role>>> getAll();
  Future<Either<Failure, Role>> getById(int id);
  Future<Either<Failure, Role>> update(Role role);
  Future<Either<Failure, bool>> delete(int id);
}
