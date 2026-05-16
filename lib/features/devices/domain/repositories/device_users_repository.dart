import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/device_users_page.dart';

abstract class DeviceUsersRepository {
  Future<Either<Failure, DeviceUsersPage>> getUsers({
    required int page,
    required int size,
  });
}
