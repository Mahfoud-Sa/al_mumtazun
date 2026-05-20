import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../features/auth/data/models/auth_session_model.dart';

class SecureAuthStorage {
  static const _tokenKey = 'auth_token';
  static const _expiresAtKey = 'auth_expires_at';
  static const _userKey = 'auth_user';
  static const _profileCacheKey = 'cached_profile_user';
  static const _legacyUserKey = 'cached_user';
  static const _profileImageUrlKey = 'profile_image_url';

  final FlutterSecureStorage storage;

  const SecureAuthStorage({FlutterSecureStorage? storage})
    : storage = storage ?? const FlutterSecureStorage();

  Future<void> saveSession(AuthSessionModel session) async {
    await Future.wait([
      storage.write(key: _tokenKey, value: session.token),
      storage.write(
        key: _expiresAtKey,
        value: session.expiresAt.toUtc().toIso8601String(),
      ),
      storage.write(key: _userKey, value: jsonEncode(session.user.toJson())),
      storage.write(
        key: _profileCacheKey,
        value: jsonEncode(session.user.toJson()),
      ),
    ]);
  }

  Future<AuthSessionModel?> readSession() async {
    final token = await storage.read(key: _tokenKey);
    final expiresAtValue = await storage.read(key: _expiresAtKey);
    final userValue = await storage.read(key: _userKey);

    if (token == null || token.isEmpty || userValue == null) return null;

    final expiresAt =
        DateTime.tryParse(expiresAtValue ?? '') ?? _expiresAtFromJwt(token);
    final decodedUser = jsonDecode(userValue);
    if (decodedUser is! Map<String, dynamic>) return null;

    return AuthSessionModel.fromJson({
      'token': token,
      'expiresAt': expiresAt.toUtc().toIso8601String(),
      'user': decodedUser,
    });
  }

  Future<String?> readToken() async {
    final session = await readSession();
    if (session == null || session.isExpired) return null;
    return session.token;
  }

  Future<void> clear() async {
    await Future.wait([
      storage.delete(key: _tokenKey),
      storage.delete(key: _expiresAtKey),
      storage.delete(key: _userKey),
      storage.delete(key: _profileCacheKey),
      storage.delete(key: _legacyUserKey),
      storage.delete(key: _profileImageUrlKey),
    ]);
  }

  DateTime _expiresAtFromJwt(String token) {
    try {
      return JwtDecoder.getExpirationDate(token).toUtc();
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }
  }
}
