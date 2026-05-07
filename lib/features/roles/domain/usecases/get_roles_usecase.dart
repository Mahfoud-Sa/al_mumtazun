import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/role.dart';
import '../repositories/role_repository.dart';

class GetRolesUseCase implements UseCase<List<Role>, NoParams> {
  final RoleRepository repository;
  GetRolesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Role>>> call(NoParams params) async {
    return repository.getAll();
  }
}
