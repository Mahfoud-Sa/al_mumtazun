import 'package:equatable/equatable.dart';

class ProfileUser extends Equatable {
  final int? id;
  final String fullName;
  final String phoneNumber;
  final double salary;
  final double workPercentage;
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
    this.salary = 0,
    this.workPercentage = 0,
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
    double? salary,
    double? workPercentage,
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
      salary: salary ?? this.salary,
      workPercentage: workPercentage ?? this.workPercentage,
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
    salary,
    workPercentage,
    birthDay,
    employeDate,
    address,
    role,
    isActive,
    profileImageUrl,
  ];
}
