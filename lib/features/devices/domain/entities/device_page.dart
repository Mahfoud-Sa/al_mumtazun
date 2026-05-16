import 'package:equatable/equatable.dart';

import 'device.dart';

class DevicePage extends Equatable {
  final List<Device> devices;
  final int page;
  final int size;
  final int totalCount;
  final int totalPages;

  const DevicePage({
    required this.devices,
    required this.page,
    required this.size,
    required this.totalCount,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [devices, page, size, totalCount, totalPages];
}
