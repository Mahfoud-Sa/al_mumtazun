import '../entities/profile_user.dart';

abstract class ProfileRepository {
  Future<ProfileUser?> getCurrentProfile();
  Future<ProfileUser> refreshProfile(ProfileUser currentProfile);
  Future<ProfileUser> updateProfile(ProfileUser profile);
  Future<void> changePassword({
    required ProfileUser profile,
    required String currentPassword,
    required String newPassword,
  });
  Future<ProfileUser?> updateProfileImageUrl(String? imageUrl);
  Future<void> clearProfile();
}
