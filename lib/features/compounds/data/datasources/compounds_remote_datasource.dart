import 'dart:convert';

import '../../../../core/clients/http_client.dart';
import '../../domain/entities/compound_page.dart';
import '../models/compound_model.dart';

abstract class CompoundsRemoteDataSource {
  Future<CompoundPage> getCompounds({required int page, required int size});
  Future<CompoundModel> createCompound(CompoundModel compound);
}

class CompoundsRemoteDataSourceImpl implements CompoundsRemoteDataSource {
  final AppHttpClient client;
  final Uri baseUri;

  CompoundsRemoteDataSourceImpl(this.client, {Uri? baseUri})
    : baseUri =
          baseUri ??
          Uri.parse('http://al-mumtazun-api.runasp.net/api/Component');

  @override
  Future<CompoundPage> getCompounds({
    required int page,
    required int size,
  }) async {
    final response = await client.get(
      baseUri.replace(
        queryParameters: {'page': page.toString(), 'size': size.toString()},
      ),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode} ${response.reasonPhrase}');
    }

    if (response.body.trim().isEmpty) {
      return CompoundPage(
        compounds: const [],
        page: page,
        size: size,
        totalCount: 0,
        totalPages: 1,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      final compounds = decoded
          .whereType<Map<String, dynamic>>()
          .map(CompoundModel.fromJson)
          .toList();
      return CompoundPage(
        compounds: compounds,
        page: page,
        size: size,
        totalCount: compounds.length,
        totalPages: compounds.isEmpty ? 1 : 1,
      );
    }

    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is List) {
        final compounds = data
            .whereType<Map<String, dynamic>>()
            .map(CompoundModel.fromJson)
            .toList();
        return CompoundPage(
          compounds: compounds,
          page: _readInt(decoded['page'], page),
          size: _readInt(decoded['size'], size),
          totalCount: _readInt(decoded['totalCount'], compounds.length),
          totalPages: _readInt(decoded['totalPages'], 1).clamp(1, 999999),
        );
      }
      return CompoundPage(
        compounds: [CompoundModel.fromJson(decoded)],
        page: page,
        size: size,
        totalCount: 1,
        totalPages: 1,
      );
    }

    throw Exception('Unexpected response format');
  }

  @override
  Future<CompoundModel> createCompound(CompoundModel compound) async {
    final response = await client.post(
      baseUri,
      headers: {'accept': 'text/plain', 'Content-Type': 'application/json'},
      body: jsonEncode(compound.toJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode} ${response.reasonPhrase}');
    }

    if (response.body.trim().isEmpty) return compound;

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return CompoundModel.fromJson(decoded);
    }

    return compound;
  }

  int _readInt(dynamic value, int fallback) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
