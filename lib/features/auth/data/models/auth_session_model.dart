import 'package:jwt_decoder/jwt_decoder.dart';

import 'user_model.dart';

class AuthSessionModel {
  final String token;
  final DateTime expiresAt;
  final UserModel user;

  const AuthSessionModel({
    required this.token,
    required this.expiresAt,
    required this.user,
  });

  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt.toUtc());

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    final token = json['token']?.toString() ?? '';
    final userJson = json['user'];
    return AuthSessionModel(
      token: token,
      expiresAt: _readExpiresAt(json, token),
      user: UserModel.fromJson(
        userJson is Map<String, dynamic> ? userJson : <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'expiresAt': expiresAt.toUtc().toIso8601String(),
    'user': user.toJson(),
  };

  static DateTime _readExpiresAt(Map<String, dynamic> json, String token) {
    for (final key in const [
      'expiresAt',
      'ExpiresAt',
      'expires_at',
      'expiration',
      'Expiration',
      'expirationDate',
      'tokenExpiresAt',
      'validTo',
    ]) {
      final parsed = _parseDate(json[key]);
      if (parsed != null) return parsed;
    }

    if (token.isNotEmpty) {
      try {
        return JwtDecoder.getExpirationDate(token).toUtc();
      } catch (_) {
        // Fall through to expired sentinel below.
      }
    }

    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      final isMilliseconds = value > 9999999999;
      return DateTime.fromMillisecondsSinceEpoch(
        isMilliseconds ? value : value * 1000,
        isUtc: true,
      );
    }

    if (value is num) {
      return _parseDate(value.toInt());
    }

    final text = value.toString().trim();
    if (text.isEmpty) return null;

    final parsed = DateTime.tryParse(text);
    if (parsed != null) return parsed.toUtc();

    final numeric = int.tryParse(text);
    if (numeric != null) return _parseDate(numeric);

    return null;
  }
}
