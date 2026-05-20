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

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode} ${response.reasonPhrase}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
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
}
