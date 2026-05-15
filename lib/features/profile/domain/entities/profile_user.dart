import 'package:equatable/equatable.dart';

class ProfileUser extends Equatable {
  final int? id;
  final String fullName;
  final String phoneNumber;
  final String birthDay;
  final String employeDate;
  final String address;
  final String role;
  final bool isActive;
  final String? profileImageUrl;

  const ProfileUser({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.birthDay,
    required this.employeDate,
    required this.address,
    required this.role,
    required this.isActive,
    this.profileImageUrl,
  });

  ProfileUser copyWith({
    int? id,
    String? fullName,
    String? phoneNumber,
    String? birthDay,
    String? employeDate,
    String? address,
    String? role,
    bool? isActive,
    String? profileImageUrl,
    bool clearProfileImageUrl = false,
  }) {
    return ProfileUser(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      birthDay: birthDay ?? this.birthDay,
      employeDate: employeDate ?? this.employeDate,
      address: address ?? this.address,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      profileImageUrl: clearProfileImageUrl
          ? null
          : profileImageUrl ?? this.profileImageUrl,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    phoneNumber,
    birthDay,
    employeDate,
    address,
    role,
    isActive,
    profileImageUrl,
  ];
}
