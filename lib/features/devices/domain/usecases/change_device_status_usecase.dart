import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/device.dart';
import '../repositories/device_repository.dart';

class ChangeDeviceStatusUseCase {
  final DeviceRepository repository;

  ChangeDeviceStatusUseCase(this.repository);

  Future<Either<Failure, Unit>> call(ChangeDeviceStatusParams params) {
    return repository.changeStatus(id: params.id, status: params.status);
  }
}

class ChangeDeviceStatusParams {
  final String id;
  final DeviceStatus status;

  const ChangeDeviceStatusParams({required this.id, required this.status});
}
