import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/device_users_page.dart';
import '../../domain/repositories/device_users_repository.dart';
import '../datasources/device_users_remote_datasource.dart';

class DeviceUsersRepositoryImpl implements DeviceUsersRepository {
  final DeviceUsersRemoteDataSource remote;

  DeviceUsersRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, DeviceUsersPage>> getUsers({
    required int page,
    required int size,
  }) async {
    try {
      final usersPage = await remote.getUsers(page: page, size: size);
      return Right(usersPage);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }
}
