import '../../domain/entities/profile_user.dart';

class ProfileUserModel extends ProfileUser {
  const ProfileUserModel({
    required super.id,
    required super.fullName,
    required super.phoneNumber,
    required super.birthDay,
    required super.employeDate,
    required super.address,
    required super.role,
    required super.isActive,
    super.profileImageUrl,
  });

  factory ProfileUserModel.fromJson(Map<String, dynamic> json) {
    return ProfileUserModel(
      id: _readInt(json['id'] ?? json['userId']),
      fullName: _readString(json['fullName'] ?? json['name']),
      phoneNumber: _readString(json['phoneNumber']),
      birthDay: _readString(json['birthDay']),
      employeDate: _readString(json['employeDate']),
      address: _readString(json['address']),
      role: _readString(json['role']),
      isActive: json['isActive'] == true,
      profileImageUrl: _readNullableString(
        json['profileImageUrl'] ?? json['imageUrl'] ?? json['avatarUrl'],
      ),
    );
  }

  factory ProfileUserModel.fromEntity(ProfileUser user) {
    return ProfileUserModel(
      id: user.id,
      fullName: user.fullName,
      phoneNumber: user.phoneNumber,
      birthDay: user.birthDay,
      employeDate: user.employeDate,
      address: user.address,
      role: user.role,
      isActive: user.isActive,
      profileImageUrl: user.profileImageUrl,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    'birthDay': birthDay,
    'employeDate': employeDate,
    'address': address,
    'role': role,
    'isActive': isActive,
    'profileImageUrl': profileImageUrl,
  };

  static int? _readInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static String _readString(dynamic value) => value?.toString() ?? '';

  static String? _readNullableString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }
}
