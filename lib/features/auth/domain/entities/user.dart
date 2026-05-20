import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String fullName;
  final String phoneNumber;
  final String role;
  final String roleDisplayName;
  final bool isActive;

  const User({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
    required this.roleDisplayName,
    required this.isActive,
  });

  bool hasRole(String value) => role.toLowerCase() == value.toLowerCase();

  @override
  List<Object?> get props => [
    id,
    fullName,
    phoneNumber,
    role,
    roleDisplayName,
    isActive,
  ];
}
