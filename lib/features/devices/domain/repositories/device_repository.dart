import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/device.dart';
import '../entities/device_page.dart';

abstract class DeviceRepository {
  Future<Either<Failure, DevicePage>> getDevices({
    required int page,
    required int size,
  });
  Future<Either<Failure, Device>> createDevice(Device device);
}
