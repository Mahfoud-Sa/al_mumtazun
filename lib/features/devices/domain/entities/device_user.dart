import 'package:equatable/equatable.dart';

class DeviceUser extends Equatable {
  final int id;
  final String name;
  final String phoneNumber;
  final String role;

  const DeviceUser({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.role,
  });

  @override
  List<Object?> get props => [id, name, phoneNumber, role];
}
