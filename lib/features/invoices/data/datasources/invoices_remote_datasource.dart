import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/clients/http_client.dart';
import '../../domain/entities/invoice_page.dart';
import '../../domain/entities/invoice_query.dart';
import '../models/invoice_model.dart';

abstract class InvoicesRemoteDataSource {
  Future<InvoicePage> getInvoices({required InvoiceQuery query});
  Future<InvoiceModel> getInvoiceById(int id);
  Future<InvoiceModel?> getInvoiceByDeviceId(int deviceId);
  Future<InvoiceModel> createInvoice(InvoiceModel invoice);
  Future<InvoiceModel> updateInvoice(int id, InvoiceModel invoice);
  Future<void> deleteInvoice(int id);
}

class InvoicesRemoteDataSourceImpl implements InvoicesRemoteDataSource {
  final AppHttpClient client;
  final Uri baseUri;

  InvoicesRemoteDataSourceImpl(this.client, {Uri? baseUri})
    : baseUri =
          baseUri ??
          Uri.parse('http://al-mumtazun-api.runasp.net/api/Invoices');

  @override
  Future<InvoiceModel> createInvoice(InvoiceModel invoice) async {
    final response = await client.post(
      baseUri,
      headers: {'accept': '*/*', 'Content-Type': 'application/json'},
      body: jsonEncode(invoice.toCreateJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }

    final created = response.body.trim().isEmpty
        ? invoice
        : _decodeInvoice(response.body, fallback: invoice);

    return created;
  }

  @override
  Future<InvoiceModel> getInvoiceById(int id) async {
    final response = await client.get(
      baseUri.replace(path: '${baseUri.path}/$id'),
      headers: {'accept': '*/*'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }

    return _decodeInvoice(response.body);
  }

  @override
  Future<InvoiceModel?> getInvoiceByDeviceId(int deviceId) async {
    final invoicesPage = await getInvoices(
      query: InvoiceQuery(deviceId: deviceId, size: 100),
    );

    for (final invoice in invoicesPage.invoices) {
      if (invoice.deviceId == deviceId) {
        return InvoiceModel.fromEntity(invoice);
      }
    }

    return null;
  }

  @override
  Future<InvoiceModel> updateInvoice(int id, InvoiceModel invoice) async {
    final response = await client.put(
      baseUri.replace(path: '${baseUri.path}/$id'),
      headers: {'accept': '*/*', 'Content-Type': 'application/json'},
      body: jsonEncode(invoice.toCreateJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }

    final updated = response.body.trim().isEmpty
        ? invoice
        : _decodeInvoice(response.body, fallback: invoice);

    return updated;
  }

  @override
  Future<void> deleteInvoice(int id) async {
    final response = await client.delete(
      baseUri.replace(path: '${baseUri.path}/$id'),
      headers: {'accept': '*/*'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }
  }

  @override
  Future<InvoicePage> getInvoices({required InvoiceQuery query}) async {
    final response = await _getInvoicesResponse(query: query);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }

    if (response.body.trim().isEmpty) {
      return InvoicePage(
        invoices: const [],
        page: query.page,
        size: query.size,
        totalCount: 0,
        totalPages: 1,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      final invoices = decoded
          .whereType<Map<String, dynamic>>()
          .map(InvoiceModel.fromJson)
          .toList();
      return InvoicePage(
        invoices: invoices,
        page: query.page,
        size: query.size,
        totalCount: invoices.length,
        totalPages: invoices.length < query.size ? query.page : query.page + 1,
      );
    }

    if (decoded is Map<String, dynamic>) {
      final data = _readList(decoded);
      if (data != null) {
        final invoices = data
            .whereType<Map<String, dynamic>>()
            .map(InvoiceModel.fromJson)
            .toList();
        return InvoicePage(
          invoices: invoices,
          page: _readInt(decoded['page'] ?? decoded['pageNumber'], query.page),
          size: _readInt(decoded['size'] ?? decoded['pageSize'], query.size),
          totalCount: _readInt(
            decoded['totalCount'] ?? decoded['count'] ?? decoded['total'],
            invoices.length,
          ),
          totalPages: _readInt(
            decoded['totalPages'] ?? decoded['pages'],
            invoices.length < query.size ? query.page : query.page + 1,
          ).clamp(1, 999999),
        );
      }

      return InvoicePage(
        invoices: [InvoiceModel.fromJson(decoded)],
        page: query.page,
        size: query.size,
        totalCount: 1,
        totalPages: 1,
      );
    }

    throw Exception('Unexpected invoices response format');
  }

  Future<http.Response> _getInvoicesResponse({
    required InvoiceQuery query,
  }) async {
    final queryParameters = query.toQueryParameters();
    final response = await client.get(
      baseUri.replace(queryParameters: queryParameters),
      headers: {'accept': '*/*'},
    );

    if (response.statusCode != 404 && response.statusCode != 405) {
      return response;
    }

    final fallbackPath = baseUri.path.endsWith('Invoices')
        ? baseUri.path.substring(0, baseUri.path.length - 1)
        : '${baseUri.path}s';
    final fallbackUri = baseUri.replace(
      path: fallbackPath,
      queryParameters: queryParameters,
    );
    return client.get(fallbackUri, headers: {'accept': '*/*'});
  }

  List<dynamic>? _readList(Map<String, dynamic> json) {
    for (final key in const ['data', 'items', 'results', 'invoices']) {
      final value = json[key];
      if (value is List) return value;
    }
    return null;
  }

  int _readInt(dynamic value, int fallback) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  String _errorMessage(http.Response response) {
    final body = response.body.trim();
    final status = 'HTTP ${response.statusCode} ${response.reasonPhrase}';
    return body.isEmpty ? status : '$status: $body';
  }

  InvoiceModel _decodeInvoice(String body, {InvoiceModel? fallback}) {
    if (body.trim().isEmpty) {
      if (fallback != null) return fallback;
      throw Exception('Empty invoice response');
    }

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'] ?? decoded['invoice'];
      if (data is Map<String, dynamic>) return InvoiceModel.fromJson(data);
      return InvoiceModel.fromJson(decoded);
    }

    if (fallback != null) return fallback;
    throw Exception('Unexpected invoice response format');
  }
}
