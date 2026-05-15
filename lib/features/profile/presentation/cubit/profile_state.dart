import 'package:equatable/equatable.dart';

import '../../domain/entities/profile_user.dart';

class ProfileState extends Equatable {
  final ProfileUser? profile;
  final bool isLoading;
  final bool isSavingProfile;
  final bool isSavingPassword;
  final String? error;
  final String? successMessage;

  const ProfileState({
    required this.profile,
    required this.isLoading,
    required this.isSavingProfile,
    required this.isSavingPassword,
    this.error,
    this.successMessage,
  });

  factory ProfileState.initial() {
    return const ProfileState(
      profile: null,
      isLoading: false,
      isSavingProfile: false,
      isSavingPassword: false,
    );
  }

  ProfileState copyWith({
    ProfileUser? profile,
    bool? isLoading,
    bool? isSavingProfile,
    bool? isSavingPassword,
    String? error,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isSavingProfile: isSavingProfile ?? this.isSavingProfile,
      isSavingPassword: isSavingPassword ?? this.isSavingPassword,
      error: clearMessages ? null : error,
      successMessage: clearMessages ? null : successMessage,
    );
  }

  @override
  List<Object?> get props => [
    profile,
    isLoading,
    isSavingProfile,
    isSavingPassword,
    error,
    successMessage,
  ];
}
