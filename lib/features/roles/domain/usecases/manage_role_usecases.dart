import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/role.dart';
import '../repositories/role_repository.dart';

class CreateRoleUseCase implements UseCase<Role, Role> {
  final RoleRepository repository;
  CreateRoleUseCase(this.repository);

  @override
  Future<Either<Failure, Role>> call(Role params) async =>
      repository.create(params);
}

class UpdateRoleUseCase implements UseCase<Role, Role> {
  final RoleRepository repository;
  UpdateRoleUseCase(this.repository);

  @override
  Future<Either<Failure, Role>> call(Role params) async =>
      repository.update(params);
}

class DeleteRoleUseCase implements UseCase<bool, String> {
  final RoleRepository repository;
  DeleteRoleUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String params) async =>
      repository.delete(params);
}
