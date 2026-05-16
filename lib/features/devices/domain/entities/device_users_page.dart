import 'package:equatable/equatable.dart';

import 'device_user.dart';

class DeviceUsersPage extends Equatable {
  final List<DeviceUser> users;
  final int page;
  final int size;
  final int totalCount;
  final int totalPages;

  const DeviceUsersPage({
    required this.users,
    required this.page,
    required this.size,
    required this.totalCount,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [users, page, size, totalCount, totalPages];
}
