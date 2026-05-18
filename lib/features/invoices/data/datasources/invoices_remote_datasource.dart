import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/clients/http_client.dart';
import '../../domain/entities/invoice_page.dart';
import '../models/invoice_model.dart';

abstract class InvoicesRemoteDataSource {
  Future<InvoicePage> getInvoices({required int page, required int size});
  Future<InvoiceModel> getInvoiceById(int id);
  Future<InvoiceModel?> getInvoiceByDeviceId(int deviceId);
  Future<InvoiceModel> createInvoice(InvoiceModel invoice);
  Future<InvoiceModel> updateInvoice(int id, InvoiceModel invoice);
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

    return created.id == 0 ? created : getInvoiceById(created.id);
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
    final invoicesPage = await getInvoices(page: 1, size: 100);

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

    return getInvoiceById(updated.id == 0 ? id : updated.id);
  }

  @override
  Future<InvoicePage> getInvoices({
    required int page,
    required int size,
  }) async {
    final response = await _getInvoicesResponse(page: page, size: size);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }

    if (response.body.trim().isEmpty) {
      return InvoicePage(
        invoices: const [],
        page: page,
        size: size,
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
        page: page,
        size: size,
        totalCount: invoices.length,
        totalPages: invoices.length < size ? page : page + 1,
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
          page: _readInt(decoded['page'] ?? decoded['pageNumber'], page),
          size: _readInt(decoded['size'] ?? decoded['pageSize'], size),
          totalCount: _readInt(
            decoded['totalCount'] ?? decoded['count'] ?? decoded['total'],
            invoices.length,
          ),
          totalPages: _readInt(
            decoded['totalPages'] ?? decoded['pages'],
            invoices.length < size ? page : page + 1,
          ).clamp(1, 999999),
        );
      }

      return InvoicePage(
        invoices: [InvoiceModel.fromJson(decoded)],
        page: page,
        size: size,
        totalCount: 1,
        totalPages: 1,
      );
    }

    throw Exception('Unexpected invoices response format');
  }

  Future<http.Response> _getInvoicesResponse({
    required int page,
    required int size,
  }) async {
    final queryParameters = {'page': page.toString(), 'size': size.toString()};
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
