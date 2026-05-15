import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile_user_model.dart';

abstract class ProfileLocalDataSource {
  Future<ProfileUserModel?> getCachedProfile();
  Future<void> cacheProfile(ProfileUserModel profile);
  Future<void> saveProfileImageUrl(String? imageUrl);
  Future<void> clearProfile();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  static const profileKey = 'cached_profile_user';
  static const legacyUserKey = 'cached_user';
  static const imageUrlKey = 'profile_image_url';

  final SharedPreferences prefs;

  ProfileLocalDataSourceImpl(this.prefs);

  @override
  Future<ProfileUserModel?> getCachedProfile() async {
    final source =
        prefs.getString(profileKey) ?? prefs.getString(legacyUserKey);
    if (source == null || source.isEmpty) return null;

    final jsonMap = json.decode(source) as Map<String, dynamic>;
    final imageUrl = prefs.getString(imageUrlKey);
    return ProfileUserModel.fromJson({
      ...jsonMap,
      if (imageUrl != null && imageUrl.isNotEmpty) 'profileImageUrl': imageUrl,
    });
  }

  @override
  Future<void> cacheProfile(ProfileUserModel profile) async {
    await prefs.setString(profileKey, json.encode(profile.toJson()));
  }

  @override
  Future<void> saveProfileImageUrl(String? imageUrl) async {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      await prefs.remove(imageUrlKey);
      return;
    }

    await prefs.setString(imageUrlKey, imageUrl.trim());
  }

  @override
  Future<void> clearProfile() async {
    await prefs.remove(profileKey);
    await prefs.remove(imageUrlKey);
  }
}
