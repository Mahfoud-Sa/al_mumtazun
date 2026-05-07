import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class LoginParams {
  final String email;
  final String password;
  LoginParams(this.email, this.password);
}

class LoginUseCase implements UseCase<User, LoginParams> {
  final UserRepository repository;
  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    return repository.login(params.email, params.password);
  }
}
