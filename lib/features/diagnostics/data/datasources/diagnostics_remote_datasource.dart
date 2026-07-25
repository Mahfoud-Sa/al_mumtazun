import 'dart:convert';

import '../../../../core/clients/http_client.dart';
import '../../domain/entities/diagnostic_page.dart';
import '../models/diagnostic_model.dart';

abstract class DiagnosticsRemoteDataSource {
  Future<DiagnosticPage> getDiagnostics({
    required int page,
    required int size,
    String? search,
    String? severity,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    String? sortBy,
    String? sortDirection,
  });
  Future<DiagnosticModel> getDiagnosticById(int id);
  Future<DiagnosticModel> createDiagnostic(DiagnosticModel diagnostic);
  Future<DiagnosticModel> updateDiagnostic(DiagnosticModel diagnostic);
  Future<DiagnosticModel> changeStatus(int id, String newStatus);
  Future<void> deleteDiagnostic(int id);
}

class DiagnosticsRemoteDataSourceImpl implements DiagnosticsRemoteDataSource {
  final AppHttpClient client;
  final Uri baseUri;

  // In-memory fallback list to provide rich initial operational data
  final List<DiagnosticModel> _localItems = [
    DiagnosticModel(
      id: 101,
      diagnosticCode: 'DIAG-101',
      title: 'ارتفاع حرارة وحدة المعالجة الرئيسية',
      subtitle: 'سخونة زائدة عند الأحمال الكبيرة',
      description: 'لوحظ ارتفاع درجة حرارة المعالج المركزي فوق 85 درجة مئوية أثناء التشغيل المستمر لمدرة 3 ساعات.',
      symptoms: 'بطء الاستجابة، ضوضاء مرتقعة من المروحة، إعادة تشغيل مفاجئ.',
      possibleCause: 'تلف معجون التبريد الفني أو تراكم الأتربة على مراوح التبريد.',
      recommendedSolution: 'تنظيف وحدة التبريد بالهواء المضغوط واستبدال المعجون الحراري.',
      images: const ['https://picsum.photos/400/250?random=1'],
      severity: 'عالي',
      status: 'قيد المعالجة',
      technicianName: 'م. أحمد خالد',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    DiagnosticModel(
      id: 102,
      diagnosticCode: 'DIAG-102',
      title: 'انخفاض جهد التغذية في كارت التحكم',
      subtitle: 'ذبذبة في التيار المستمر',
      description: 'قراءات قياس الجهد تظهر انخفاضاً من 12V إلى 9.8V عند دخول الريليهات في الخدمة.',
      symptoms: 'إعادة ضبط تلقائي للشاشة الرئيسية وتعطل الاتصال التسلسلي.',
      possibleCause: 'جفاف المكثفات الإلكتروليتية في وحدة التغذية الكهربائية (Power Supply).',
      recommendedSolution: 'فحص واستبدال المكثفات المتضررة بقيمة 1000uF 25V.',
      images: const ['https://picsum.photos/400/250?random=2'],
      severity: 'حرج',
      status: 'قيد الانتظار',
      technicianName: 'م. محمود علي',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    DiagnosticModel(
      id: 103,
      diagnosticCode: 'DIAG-103',
      title: 'خطأ اتصال بروتوكول Modbus RS485',
      subtitle: 'انقطاع الإشارة مع المستشعرات الخارجية',
      description: 'توقف استقبال البيانات من مستشعرات الضغط عبر خط الاتصال التسلسلي.',
      symptoms: 'ظهور ترميز الخطأ E-404 على لوحة القيادة.',
      possibleCause: 'تلف شريحة MAX485 Transceiver أو انقطاع في خط التوصيل الأرضي.',
      recommendedSolution: 'قياس المقاومة على طرفي A-B واختبار الشريحة المنفردة.',
      images: const ['https://picsum.photos/400/250?random=3'],
      severity: 'متوسط',
      status: 'تم الحل',
      technicianName: 'م. سارة حسن',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    DiagnosticModel(
      id: 104,
      diagnosticCode: 'DIAG-104',
      title: 'تذبذب قراءات مستشعر الحرارة PT100',
      subtitle: 'ضوضاء كهربائية على خط الدخل التناظري',
      description: 'القراءات تتأرجح بمدى ±15 درجة مئوية بشكل غير منتظم.',
      symptoms: 'قراءات غير منطقية على شاشة المراقبة.',
      possibleCause: 'عدم وجود تأريض مناسب لغلاف الكابل الشيلد (Shielded Cable).',
      recommendedSolution: 'ربط غلاف الكابل بنقطة الأرضي الخاصة باللوحة الرئيسية.',
      images: const ['https://picsum.photos/400/250?random=4'],
      severity: 'منخفض',
      status: 'مغلق',
      technicianName: 'م. عمر طارق',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  DiagnosticsRemoteDataSourceImpl(this.client, {Uri? baseUri})
      : baseUri =
            baseUri ?? Uri.parse('http://al-mumtazun-api.runasp.net/api/diagnostics');

  @override
  Future<DiagnosticPage> getDiagnostics({
    required int page,
    required int size,
    String? search,
    String? severity,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    String? sortBy,
    String? sortDirection,
  }) async {
    try {
      final queryParameters = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };
      if (search != null && search.trim().isNotEmpty) {
        queryParameters['search'] = search.trim();
      }
      if (severity != null && severity.trim().isNotEmpty) {
        queryParameters['severity'] = severity.trim();
      }
      if (status != null && status.trim().isNotEmpty) {
        queryParameters['status'] = status.trim();
      }
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

      if (response.statusCode >= 200 && response.statusCode < 300 && response.body.trim().isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          final items = decoded
              .whereType<Map<String, dynamic>>()
              .map(DiagnosticModel.fromJson)
              .toList();
          return _filterAndPaginate(items, page, size, search, severity, status, fromDate, toDate, sortBy, sortDirection);
        } else if (decoded is Map<String, dynamic> && decoded['data'] is List) {
          final data = decoded['data'] as List;
          final items = data
              .whereType<Map<String, dynamic>>()
              .map(DiagnosticModel.fromJson)
              .toList();
          return DiagnosticPage(
            diagnostics: items,
            page: _readInt(decoded['page'], page),
            size: _readInt(decoded['size'], size),
            totalCount: _readInt(decoded['totalCount'], items.length),
            totalPages: _readInt(decoded['totalPages'], 1).clamp(1, 999999),
          );
        }
      }
    } catch (_) {
      // Fallback to local memory storage when remote endpoint is not present or offline
    }

    return _filterAndPaginate(_localItems, page, size, search, severity, status, fromDate, toDate, sortBy, sortDirection);
  }

  DiagnosticPage _filterAndPaginate(
    List<DiagnosticModel> source,
    int page,
    int size,
    String? search,
    String? severity,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    String? sortBy,
    String? sortDirection,
  ) {
    var filtered = List<DiagnosticModel>.from(source);

    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      filtered = filtered.where((item) {
        return item.title.toLowerCase().contains(q) ||
            (item.subtitle?.toLowerCase().contains(q) ?? false) ||
            (item.description?.toLowerCase().contains(q) ?? false) ||
            (item.diagnosticCode.toLowerCase().contains(q)) ||
            (item.technicianName?.toLowerCase().contains(q) ?? false) ||
            (item.symptoms?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    if (severity != null && severity.trim().isNotEmpty && severity != 'الكل') {
      filtered = filtered.where((item) => item.severity == severity).toList();
    }

    if (status != null && status.trim().isNotEmpty && status != 'الكل') {
      filtered = filtered.where((item) => item.status == status).toList();
    }

    if (fromDate != null) {
      filtered = filtered.where((item) => item.createdAt.isAfter(fromDate.subtract(const Duration(seconds: 1)))).toList();
    }

    if (toDate != null) {
      filtered = filtered.where((item) => item.createdAt.isBefore(toDate.add(const Duration(days: 1)))).toList();
    }

    final isAsc = (sortDirection ?? 'asc').toLowerCase() == 'asc';
    filtered.sort((a, b) {
      int comp = 0;
      switch (sortBy) {
        case 'title':
          comp = a.title.compareTo(b.title);
          break;
        case 'severity':
          comp = a.severity.compareTo(b.severity);
          break;
        case 'status':
          comp = a.status.compareTo(b.status);
          break;
        case 'date':
          comp = a.createdAt.compareTo(b.createdAt);
          break;
        case 'id':
        default:
          comp = a.id.compareTo(b.id);
          break;
      }
      return isAsc ? comp : -comp;
    });

    final totalCount = filtered.length;
    final totalPages = (totalCount / size).ceil().clamp(1, 999999);
    final startIndex = ((page - 1) * size).clamp(0, totalCount);
    final endIndex = (startIndex + size).clamp(0, totalCount);

    final pagedItems = startIndex < totalCount ? filtered.sublist(startIndex, endIndex) : <DiagnosticModel>[];

    return DiagnosticPage(
      diagnostics: pagedItems,
      page: page,
      size: size,
      totalCount: totalCount,
      totalPages: totalPages,
    );
  }

  @override
  Future<DiagnosticModel> getDiagnosticById(int id) async {
    try {
      final response = await client.get(
        _itemUri(id),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300 && response.body.trim().isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final model = DiagnosticModel.fromJson(decoded);
          _updateLocal(model);
          return model;
        }
      }
    } catch (_) {}

    return _localItems.firstWhere(
      (item) => item.id == id,
      orElse: () => throw Exception('Diagnostic entry not found'),
    );
  }

  @override
  Future<DiagnosticModel> createDiagnostic(DiagnosticModel diagnostic) async {
    try {
      final response = await client.post(
        baseUri,
        headers: {'accept': 'application/json', 'Content-Type': 'application/json'},
        body: jsonEncode(diagnostic.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300 && response.body.trim().isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('title')) {
            final created = DiagnosticModel.fromJson(decoded);
            _localItems.insert(0, created);
            return created;
          } else {
            final returnedId = _readInt(decoded['id'], diagnostic.id);
            final returnedCode = decoded['diagnosticCode']?.toString() ??
                (diagnostic.diagnosticCode.isNotEmpty ? diagnostic.diagnosticCode : 'DIAG-$returnedId');
            final created = DiagnosticModel.fromEntity(
              diagnostic.copyWith(
                id: returnedId > 0 ? returnedId : diagnostic.id,
                diagnosticCode: returnedCode,
              ),
            );
            _localItems.insert(0, created);
            return created;
          }
        }
      }
    } catch (_) {}

    final newId = _localItems.isEmpty ? 101 : (_localItems.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);
    final created = DiagnosticModel(
      id: newId,
      diagnosticCode: diagnostic.diagnosticCode.isNotEmpty ? diagnostic.diagnosticCode : 'DIAG-$newId',
      title: diagnostic.title,
      subtitle: diagnostic.subtitle,
      description: diagnostic.description,
      symptoms: diagnostic.symptoms,
      possibleCause: diagnostic.possibleCause,
      recommendedSolution: diagnostic.recommendedSolution,
      images: diagnostic.images,
      severity: diagnostic.severity,
      status: diagnostic.status,
      technicianName: diagnostic.technicianName,
      createdAt: diagnostic.createdAt,
      updatedAt: DateTime.now(),
    );
    _localItems.insert(0, created);
    return created;
  }

  @override
  Future<DiagnosticModel> updateDiagnostic(DiagnosticModel diagnostic) async {
    try {
      final response = await client.put(
        _itemUri(diagnostic.id),
        headers: {'accept': 'application/json', 'Content-Type': 'application/json'},
        body: jsonEncode(diagnostic.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300 && response.body.trim().isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('title')) {
          final updated = DiagnosticModel.fromJson(decoded);
          _updateLocal(updated);
          return updated;
        }
      }
    } catch (_) {}

    final updatedModel = DiagnosticModel.fromEntity(diagnostic.copyWith(updatedAt: DateTime.now()));
    _updateLocal(updatedModel);
    return updatedModel;
  }

  @override
  Future<DiagnosticModel> changeStatus(int id, String newStatus) async {
    try {
      final baseStr = baseUri.toString().replaceAll(RegExp(r'/$'), '');
      final changeStatusUri = Uri.parse('$baseStr/change-status/$id');

      final response = await client.put(
        changeStatusUri,
        headers: {'accept': 'application/json', 'Content-Type': 'application/json'},
        body: jsonEncode({'status': newStatus}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300 && response.body.trim().isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('title')) {
          final updated = DiagnosticModel.fromJson(decoded);
          _updateLocal(updated);
          return updated;
        }
      }
    } catch (_) {}

    final existingIdx = _localItems.indexWhere((item) => item.id == id);
    if (existingIdx != -1) {
      final updatedModel = DiagnosticModel.fromEntity(
        _localItems[existingIdx].copyWith(status: newStatus, updatedAt: DateTime.now()),
      );
      _localItems[existingIdx] = updatedModel;
      return updatedModel;
    } else {
      throw Exception('Diagnostic entry not found');
    }
  }

  @override
  Future<void> deleteDiagnostic(int id) async {
    try {
      await client.delete(
        _itemUri(id),
        headers: {'accept': '*/*'},
      );
    } catch (_) {}

    _localItems.removeWhere((item) => item.id == id);
  }

  void _updateLocal(DiagnosticModel item) {
    final idx = _localItems.indexWhere((element) => element.id == item.id);
    if (idx != -1) {
      _localItems[idx] = item;
    } else {
      _localItems.insert(0, item);
    }
  }

  int _readInt(dynamic value, int fallback) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  Uri _itemUri(int id) {
    final path = baseUri.path.endsWith('/') ? '${baseUri.path}$id' : '${baseUri.path}/$id';
    return baseUri.replace(path: path, queryParameters: null);
  }
}
