import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheCurrentUser(UserModel user);
  Future<UserModel?> getCurrentUser();
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _kUserKey = 'cached_user';
  final SharedPreferences prefs;

  AuthLocalDataSourceImpl(this.prefs);

  @override
  Future<void> cacheCurrentUser(UserModel user) async {
    await prefs.setString(_kUserKey, json.encode(user.toJson()));
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final s = prefs.getString(_kUserKey);
    if (s == null) return null;
    return UserModel.fromJson(json.decode(s) as Map<String, dynamic>);
  }

  @override
  Future<void> clearUser() async => prefs.remove(_kUserKey);
}
