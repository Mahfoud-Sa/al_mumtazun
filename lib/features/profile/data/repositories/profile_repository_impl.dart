import '../../domain/entities/profile_user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_user_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource local;
  final ProfileRemoteDataSource remote;

  ProfileRepositoryImpl({required this.local, required this.remote});

  @override
  Future<ProfileUser?> getCurrentProfile() {
    return local.getCachedProfile();
  }

  @override
  Future<ProfileUser> refreshProfile(ProfileUser currentProfile) async {
    final id = currentProfile.id;
    if (id == null) return currentProfile;

    final remoteProfile = await remote.getUser(id);
    final merged = remoteProfile.copyWith(
      profileImageUrl: currentProfile.profileImageUrl,
    );
    await local.cacheProfile(ProfileUserModel.fromEntity(merged));
    return merged;
  }

  @override
  Future<ProfileUser> updateProfile(ProfileUser profile) async {
    final id = profile.id;
    if (id == null) {
      throw Exception('لم يتم العثور على رقم المستخدم الحالي');
    }

    final updated = await remote.updateUser(
      userId: id,
      profile: ProfileUserModel.fromEntity(profile),
    );
    final merged = updated.copyWith(profileImageUrl: profile.profileImageUrl);
    await local.cacheProfile(ProfileUserModel.fromEntity(merged));
    return merged;
  }

  @override
  Future<void> changePassword({
    required ProfileUser profile,
    required String currentPassword,
    required String newPassword,
  }) async {
    final id = profile.id;
    if (id == null) {
      throw Exception('لم يتم العثور على رقم المستخدم الحالي');
    }

    await remote.changePassword(
      userId: id,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<ProfileUser?> updateProfileImageUrl(String? imageUrl) async {
    await local.saveProfileImageUrl(imageUrl);
    final cached = await local.getCachedProfile();
    if (cached == null) return null;

    final updated = cached.copyWith(
      profileImageUrl: imageUrl,
      clearProfileImageUrl: imageUrl == null || imageUrl.trim().isEmpty,
    );
    await local.cacheProfile(ProfileUserModel.fromEntity(updated));
    return updated;
  }

  @override
  Future<void> clearProfile() {
    return local.clearProfile();
  }
}
