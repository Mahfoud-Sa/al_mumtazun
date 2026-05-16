import 'dart:convert';

import '../../../../core/clients/http_client.dart';
import '../../domain/entities/device_page.dart';
import '../models/device_model.dart';

abstract class DevicesRemoteDataSource {
  Future<DevicePage> getDevices({required int page, required int size});
  Future<DeviceModel> createDevice(DeviceModel device);
}

class DevicesRemoteDataSourceImpl implements DevicesRemoteDataSource {
  final AppHttpClient client;
  final Uri baseUri;

  DevicesRemoteDataSourceImpl(this.client, {Uri? baseUri})
    : baseUri =
          baseUri ?? Uri.parse('http://al-mumtazun-api.runasp.net/api/Devices');

  @override
  Future<DevicePage> getDevices({required int page, required int size}) async {
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
      return DevicePage(
        devices: const [],
        page: page,
        size: size,
        totalCount: 0,
        totalPages: 1,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      final devices = decoded
          .whereType<Map<String, dynamic>>()
          .map(DeviceModel.fromJson)
          .toList();
      return DevicePage(
        devices: devices,
        page: page,
        size: size,
        totalCount: devices.length,
        totalPages: devices.length < size ? page : page + 1,
      );
    }

    if (decoded is Map<String, dynamic>) {
      final data = _readList(decoded);
      if (data != null) {
        final devices = data
            .whereType<Map<String, dynamic>>()
            .map(DeviceModel.fromJson)
            .toList();
        final totalCount = _readInt(
          decoded['totalCount'] ?? decoded['count'] ?? decoded['total'],
          devices.length,
        );
        return DevicePage(
          devices: devices,
          page: _readInt(decoded['page'] ?? decoded['pageNumber'], page),
          size: _readInt(decoded['size'] ?? decoded['pageSize'], size),
          totalCount: totalCount,
          totalPages: _readInt(
            decoded['totalPages'] ?? decoded['pages'],
            devices.length < size ? page : page + 1,
          ).clamp(1, 999999),
        );
      }

      return DevicePage(
        devices: [DeviceModel.fromJson(decoded)],
        page: page,
        size: size,
        totalCount: 1,
        totalPages: 1,
      );
    }

    throw Exception('Unexpected devices response format');
  }

  @override
  Future<DeviceModel> createDevice(DeviceModel device) async {
    final response = await client.post(
      baseUri,
      headers: {'accept': '*/*', 'Content-Type': 'application/json'},
      body: jsonEncode(device.toCreateJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode} ${response.reasonPhrase}');
    }

    if (response.body.trim().isEmpty) return device;

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return DeviceModel.fromJson(decoded);
    }

    return device;
  }

  List<dynamic>? _readList(Map<String, dynamic> json) {
    for (final key in const ['data', 'items', 'results', 'devices']) {
      final value = json[key];
      if (value is List) return value;
    }
    return null;
  }

  int _readInt(dynamic value, int fallback) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
