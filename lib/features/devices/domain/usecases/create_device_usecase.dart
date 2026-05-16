import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/device.dart';
import '../repositories/device_repository.dart';

class CreateDeviceUseCase {
  final DeviceRepository repository;

  CreateDeviceUseCase(this.repository);

  Future<Either<Failure, Device>> call(Device device) {
    return repository.createDevice(device);
  }
}
