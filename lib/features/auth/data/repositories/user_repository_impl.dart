import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;

  UserRepositoryImpl({required this.remote, required this.local});

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final model = await remote.login(email, password);
      await local.cacheCurrentUser(model);
      return Right(model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await local.clearUser();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await local.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register(String name, String email, String password) async {
    try {
      final model = await remote.register(name, email, password);
      await local.cacheCurrentUser(model);
      return Right(model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
