import 'dart:convert';

import '../models/user_model.dart';
import '../../../../core/clients/http_client.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String phoneNumber, String password);
  Future<UserModel> register(String name, String phoneNumber, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AppHttpClient client;

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> login(String phoneNumber, String password) async {
    final response = await client.post(
      Uri.parse('http://al-mumtazun-api.runasp.net/api/Auth/login'),
      headers: {'Content-Type': 'application/json', 'accept': '*/*'},
      body: jsonEncode({'phoneNumber': phoneNumber, 'password': password}),
    );

    final decoded = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        _messageFromResponse(
          decoded,
          response.body,
          response.statusCode,
          'فشل تسجيل الدخول',
        ),
      );
    }

    if (decoded is Map<String, dynamic>) {
      final success = decoded['success'];
      if (success == false) {
        throw Exception(_messageFromData(decoded) ?? 'فشل تسجيل الدخول');
      }

      final user = decoded['user'];
      if (user is Map<String, dynamic>) return UserModel.fromJson(user);
      return UserModel.fromJson(decoded);
    }

    throw Exception('Unexpected login response format');
  }

  @override
  Future<UserModel> register(
    String name,
    String phoneNumber,
    String password,
  ) async {
    throw UnimplementedError('Registration is not exposed by the API yet.');
  }

  Object? _decodeBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return null;

    try {
      return jsonDecode(trimmed);
    } catch (_) {
      return trimmed;
    }
  }

  String _messageFromResponse(
    Object? data,
    String body,
    int statusCode,
    String fallback,
  ) {
    final message = _messageFromData(data);
    if (message != null) return message;

    final trimmedBody = body.trim();
    if (trimmedBody.isNotEmpty) return trimmedBody;

    return '$fallback (HTTP $statusCode)';
  }

  String? _messageFromData(Object? data) {
    if (data == null) return null;

    if (data is String) {
      final message = data.trim();
      return message.isEmpty ? null : message;
    }

    if (data is List) {
      final messages = data
          .map(_messageFromData)
          .whereType<String>()
          .where((message) => message.trim().isNotEmpty)
          .toList();
      return messages.isEmpty ? null : messages.join('\n');
    }

    if (data is Map) {
      for (final key in const [
        'message',
        'error',
        'errorMessage',
        'detail',
        'title',
        'description',
      ]) {
        final message = _messageFromData(data[key]);
        if (message != null) return message;
      }

      final errors = data['errors'];
      if (errors is Map) {
        final messages = <String>[];
        for (final entry in errors.entries) {
          final message = _messageFromData(entry.value);
          if (message != null) messages.add('${entry.key}: $message');
        }
        if (messages.isNotEmpty) return messages.join('\n');
      }

      return _messageFromData(errors);
    }

    return null;
  }
}
