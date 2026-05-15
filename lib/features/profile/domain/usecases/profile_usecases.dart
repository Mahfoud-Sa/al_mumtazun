import '../entities/profile_user.dart';
import '../repositories/profile_repository.dart';

class GetCurrentProfileUseCase {
  final ProfileRepository repository;

  GetCurrentProfileUseCase(this.repository);

  Future<ProfileUser?> call() {
    return repository.getCurrentProfile();
  }
}

class RefreshProfileUseCase {
  final ProfileRepository repository;

  RefreshProfileUseCase(this.repository);

  Future<ProfileUser> call(ProfileUser currentProfile) {
    return repository.refreshProfile(currentProfile);
  }
}

class ChangePasswordUseCase {
  final ProfileRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<void> call({
    required ProfileUser profile,
    required String currentPassword,
    required String newPassword,
  }) {
    return repository.changePassword(
      profile: profile,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<ProfileUser> call(ProfileUser profile) {
    return repository.updateProfile(profile);
  }
}

class UpdateProfileImageUrlUseCase {
  final ProfileRepository repository;

  UpdateProfileImageUrlUseCase(this.repository);

  Future<ProfileUser?> call(String? imageUrl) {
    return repository.updateProfileImageUrl(imageUrl);
  }
}
