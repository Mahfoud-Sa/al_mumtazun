import 'dart:convert';

import '../../../../core/clients/http_client.dart';
import '../models/income_engineer_model.dart';
import '../models/income_entry_model.dart';

abstract class IncomesRemoteDataSource {
  Future<IncomeEntryModel> createIncome(IncomeEntryModel income);
  Future<List<IncomeEngineerModel>> getEngineers();
}

class IncomesRemoteDataSourceImpl implements IncomesRemoteDataSource {
  final AppHttpClient client;
  final Uri incomeUri;
  final Uri usersUri;

  IncomesRemoteDataSourceImpl(this.client, {Uri? incomeUri, Uri? usersUri})
    : incomeUri =
          incomeUri ??
          Uri.parse('http://al-mumtazun-api.runasp.net/api/Income'),
      usersUri =
          usersUri ?? Uri.parse('http://al-mumtazun-api.runasp.net/api/Users');

  @override
  Future<IncomeEntryModel> createIncome(IncomeEntryModel income) async {
    final response = await client.post(
      incomeUri,
      headers: {'accept': '*/*', 'Content-Type': 'application/json'},
      body: jsonEncode(income.toJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode} ${response.reasonPhrase}');
    }

    return income;
  }

  @override
  Future<List<IncomeEngineerModel>> getEngineers() async {
    final response = await client.get(
      usersUri,
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode} ${response.reasonPhrase}');
    }

    if (response.body.trim().isEmpty) return [];

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(IncomeEngineerModel.fromJson)
          .where((engineer) => engineer.id > 0)
          .toList();
    }

    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(IncomeEngineerModel.fromJson)
            .where((engineer) => engineer.id > 0)
            .toList();
      }
      final engineer = IncomeEngineerModel.fromJson(decoded);
      return engineer.id > 0 ? [engineer] : [];
    }

    throw Exception('Unexpected users response format');
  }
}
