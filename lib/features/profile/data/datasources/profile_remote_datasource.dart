import 'dart:convert';

import '../../../../core/clients/http_client.dart';

import '../models/profile_user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileUserModel> getUser(int id);
  Future<ProfileUserModel> updateUser({
    required int userId,
    required ProfileUserModel profile,
  });
  Future<void> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  static const baseUrl = 'http://al-mumtazun-api.runasp.net/api/Profile';

  final AppHttpClient client;

  ProfileRemoteDataSourceImpl({required this.client});

  @override
  Future<ProfileUserModel> getUser(int id) async {
    final response = await client.get(
      Uri.parse('$baseUrl/$id'),
      headers: {'accept': '*/*'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode} ${response.reasonPhrase}');
    }

    final body = json.decode(response.body);
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected profile response');
    }

    return ProfileUserModel.fromJson(body);
  }

  @override
  Future<ProfileUserModel> updateUser({
    required int userId,
    required ProfileUserModel profile,
  }) async {
    final response = await client.put(
      Uri.parse('$baseUrl/update/$userId'),
      headers: {'accept': '*/*', 'Content-Type': 'application/json'},
      body: json.encode({
        'fullName': profile.fullName,
        'phoneNumber': profile.phoneNumber,
        'address': profile.address,
        'birthDay': _toApiDate(profile.birthDay),
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode} ${response.reasonPhrase}');
    }

    if (response.body.isEmpty) return profile;

    final body = json.decode(response.body);
    if (body is Map<String, dynamic>) {
      return ProfileUserModel.fromJson({...profile.toJson(), ...body});
    }

    return profile;
  }

  @override
  Future<void> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await client.put(
      Uri.parse('$baseUrl/change-password/$userId'),
      headers: {'accept': '*/*', 'Content-Type': 'application/json'},
      body: json.encode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  String _toApiDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return parsed.toUtc().toIso8601String();
  }
}
