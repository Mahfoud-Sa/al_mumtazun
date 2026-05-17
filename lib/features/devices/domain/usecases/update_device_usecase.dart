import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/device.dart';
import '../repositories/device_repository.dart';

class UpdateDeviceUseCase {
  final DeviceRepository repository;

  UpdateDeviceUseCase(this.repository);

  Future<Either<Failure, Device>> call(UpdateDeviceParams params) {
    return repository.updateDevice(params.device);
  }
}

class UpdateDeviceParams {
  final Device device;

  const UpdateDeviceParams({required this.device});
}
