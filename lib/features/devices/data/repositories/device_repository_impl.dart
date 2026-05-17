import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/device_page.dart';
import '../../domain/repositories/device_repository.dart';
import '../datasources/devices_remote_datasource.dart';
import '../models/device_model.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DevicesRemoteDataSource remote;

  DeviceRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, Device>> createDevice(Device device) async {
    try {
      final created = await remote.createDevice(DeviceModel.fromEntity(device));
      return Right(created);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, Device>> updateDevice(Device device) async {
    try {
      final updated = await remote.updateDevice(DeviceModel.fromEntity(device));
      return Right(updated);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> changeStatus({
    required String id,
    required DeviceStatus status,
  }) async {
    try {
      await remote.changeStatus(id: id, status: status);
      return const Right(unit);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, DevicePage>> getDevices({
    required int page,
    required int size,
  }) async {
    try {
      final devicesPage = await remote.getDevices(page: page, size: size);
      return Right(devicesPage);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }
}
