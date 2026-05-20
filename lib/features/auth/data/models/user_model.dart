import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.phoneNumber,
    required super.role,
    required super.roleDisplayName,
    required super.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _readInt(json['id'] ?? json['userId']),
      fullName: _readString(json['fullName'] ?? json['name']),
      phoneNumber: _readString(json['phoneNumber']),
      role: _readString(json['role']),
      roleDisplayName: _readString(json['roleDisplayName'] ?? json['role']),
      isActive: _readBool(json['isActive']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    'role': role,
    'roleDisplayName': roleDisplayName,
    'isActive': isActive,
  };

  static int _readInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _readString(dynamic value) => value?.toString() ?? '';

  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
}
