import 'dart:convert';

import '../../../../core/clients/http_client.dart';
import '../../domain/entities/compound_page.dart';
import '../models/compound_model.dart';

abstract class CompoundsRemoteDataSource {
  Future<CompoundPage> getCompounds({
    required int page,
    required int size,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortDirection,
  });
  Future<CompoundModel> createCompound(CompoundModel compound);
  Future<CompoundModel> updateCompound(CompoundModel compound);
  Future<void> deleteCompound(int id);
}

class CompoundsRemoteDataSourceImpl implements CompoundsRemoteDataSource {
  final AppHttpClient client;
  final Uri baseUri;

  CompoundsRemoteDataSourceImpl(this.client, {Uri? baseUri})
    : baseUri =
          baseUri ??
          Uri.parse('http://al-mumtazun-api.runasp.net/api/spareparts');

  @override
  Future<CompoundPage> getCompounds({
    required int page,
    required int size,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortDirection,
  }) async {
    final queryParameters = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };
    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }
    if (minPrice != null) queryParameters['minPrice'] = minPrice.toString();
    if (maxPrice != null) queryParameters['maxPrice'] = maxPrice.toString();
    if (sortBy != null && sortBy.trim().isNotEmpty) {
      queryParameters['sortBy'] = sortBy.trim();
    }
    if (sortDirection != null && sortDirection.trim().isNotEmpty) {
      queryParameters['sortDirection'] = sortDirection.trim();
    }

    final response = await client.get(
      baseUri.replace(queryParameters: queryParameters),
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

  @override
  Future<CompoundModel> updateCompound(CompoundModel compound) async {
    final response = await client.put(
      _compoundUri(compound.id),
      headers: {'accept': '*/*', 'Content-Type': 'application/json'},
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

  @override
  Future<void> deleteCompound(int id) async {
    final response = await client.delete(
      _compoundUri(id),
      headers: {'accept': '*/*'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  int _readInt(dynamic value, int fallback) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  Uri _compoundUri(int id) {
    final path = baseUri.path.endsWith('/')
        ? '${baseUri.path}$id'
        : '${baseUri.path}/$id';
    return baseUri.replace(path: path, queryParameters: null);
  }
}
