import 'dart:convert';

import '../../../../core/clients/http_client.dart';
import '../../domain/entities/device_users_page.dart';
import '../models/device_user_model.dart';

abstract class DeviceUsersRemoteDataSource {
  Future<DeviceUsersPage> getUsers({required int page, required int size});
}

class DeviceUsersRemoteDataSourceImpl implements DeviceUsersRemoteDataSource {
  final AppHttpClient client;
  final Uri baseUri;

  DeviceUsersRemoteDataSourceImpl(this.client, {Uri? baseUri})
    : baseUri =
          baseUri ?? Uri.parse('http://al-mumtazun-api.runasp.net/api/Users');

  @override
  Future<DeviceUsersPage> getUsers({
    required int page,
    required int size,
  }) async {
    final response = await client.get(
      baseUri.replace(
        queryParameters: {'page': page.toString(), 'size': size.toString()},
      ),
      headers: {'accept': '*/*'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode} ${response.reasonPhrase}');
    }

    if (response.body.trim().isEmpty) {
      return DeviceUsersPage(
        users: const [],
        page: page,
        size: size,
        totalCount: 0,
        totalPages: 1,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      final users = decoded
          .whereType<Map<String, dynamic>>()
          .map(DeviceUserModel.fromJson)
          .where((user) => user.id > 0)
          .toList();
      return DeviceUsersPage(
        users: users,
        page: page,
        size: size,
        totalCount: users.length,
        totalPages: users.length < size ? page : page + 1,
      );
    }

    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is List) {
        final users = data
            .whereType<Map<String, dynamic>>()
            .map(DeviceUserModel.fromJson)
            .where((user) => user.id > 0)
            .toList();
        return DeviceUsersPage(
          users: users,
          page: _readInt(decoded['page'], page),
          size: _readInt(decoded['size'], size),
          totalCount: _readInt(decoded['totalCount'], users.length),
          totalPages: _readInt(decoded['totalPages'], 1).clamp(1, 999999),
        );
      }
    }

    throw Exception('Unexpected users response format');
  }

  int _readInt(dynamic value, int fallback) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
