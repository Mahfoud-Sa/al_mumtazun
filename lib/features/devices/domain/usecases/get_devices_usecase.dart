import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/device_page.dart';
import '../repositories/device_repository.dart';

class GetDevicesUseCase {
  final DeviceRepository repository;

  GetDevicesUseCase(this.repository);

  Future<Either<Failure, DevicePage>> call(GetDevicesParams params) {
    return repository.getDevices(
      page: params.page,
      size: params.size,
      sortBy: params.sortBy,
      sortDirection: params.sortDirection,
    );
  }
}

class GetDevicesParams {
  final int page;
  final int size;
  final String? sortBy;
  final String? sortDirection;

  const GetDevicesParams({
    required this.page,
    required this.size,
    this.sortBy,
    this.sortDirection,
  });
}
