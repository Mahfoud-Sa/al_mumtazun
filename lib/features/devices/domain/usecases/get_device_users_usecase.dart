import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/device_users_page.dart';
import '../repositories/device_users_repository.dart';

class GetDeviceUsersUseCase {
  final DeviceUsersRepository repository;

  GetDeviceUsersUseCase(this.repository);

  Future<Either<Failure, DeviceUsersPage>> call(GetDeviceUsersParams params) {
    return repository.getUsers(page: params.page, size: params.size);
  }
}

class GetDeviceUsersParams {
  final int page;
  final int size;

  const GetDeviceUsersParams({required this.page, required this.size});
}
