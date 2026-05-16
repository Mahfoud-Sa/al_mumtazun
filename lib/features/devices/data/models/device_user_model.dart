import '../../domain/entities/device_user.dart';

class DeviceUserModel extends DeviceUser {
  const DeviceUserModel({
    required super.id,
    required super.name,
    required super.phoneNumber,
    required super.role,
  });

  factory DeviceUserModel.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'] ?? json['userId'] ?? json['employeeId'];
    final id = idValue is int
        ? idValue
        : int.tryParse(idValue?.toString() ?? '') ?? 0;
    final name =
        json['fullName'] ??
        json['name'] ??
        json['userName'] ??
        json['username'] ??
        json['phoneNumber'] ??
        'مستخدم $id';

    return DeviceUserModel(
      id: id,
      name: name.toString().trim().isEmpty ? 'مستخدم $id' : name.toString(),
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }
}
