import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/clients/http_client.dart';

enum DashboardDeviceStatus {
  received,
  waiting,
  inMaintenance,
  completed,
  delivered,
}

enum DashboardResourceType { active, onLeave, available }

enum DashboardLogType { deviceOverheating, lowStock, repairCompleted }

class DashboardStatusMetric extends Equatable {
  final DashboardDeviceStatus status;
  final double value;
  final Color color;

  const DashboardStatusMetric({
    required this.status,
    required this.value,
    required this.color,
  });

  @override
  List<Object?> get props => [status, value, color];
}

class DashboardResourceMetric extends Equatable {
  final DashboardResourceType type;
  final double value;
  final Color color;

  const DashboardResourceMetric({
    required this.type,
    required this.value,
    required this.color,
  });

  @override
  List<Object?> get props => [type, value, color];
}

class DashboardIncomePoint extends Equatable {
  final String label;
  final double value;

  const DashboardIncomePoint({required this.label, required this.value});

  @override
  List<Object?> get props => [label, value];
}

class DashboardLogEntry extends Equatable {
  final DashboardLogType type;
  final String title;
  final String subtitle;
  final DateTime? date;
  final IconData icon;
  final Color color;

  const DashboardLogEntry({
    required this.type,
    required this.title,
    required this.subtitle,
    this.date,
    required this.icon,
    required this.color,
  });

  @override
  List<Object?> get props => [type, title, subtitle, date, icon, color];
}

class DashboardState extends Equatable {
  final int rangeIndex;
  final bool isLoading;
  final double totalIncome;
  final String incomeDelta;
  final double inventoryTurnover;
  final double efficiency;
  final double monthlyIncome;
  final double averageInvoiceValue;
  final int totalDevices;
  final int totalEngineering;
  final int activeEngineering;
  final int inactiveEngineering;
  final int totalComponents;
  final int usedComponents;
  final int totalInvoices;
  final List<DashboardStatusMetric> statusMetrics;
  final List<DashboardIncomePoint> incomeChart;
  final List<DashboardResourceMetric> resourceMetrics;
  final List<DashboardLogEntry> criticalLogs;
  final String? errorMessage;

  const DashboardState({
    required this.rangeIndex,
    this.isLoading = false,
    required this.totalIncome,
    required this.incomeDelta,
    required this.inventoryTurnover,
    required this.efficiency,
    required this.monthlyIncome,
    required this.averageInvoiceValue,
    required this.totalDevices,
    required this.totalEngineering,
    required this.activeEngineering,
    required this.inactiveEngineering,
    required this.totalComponents,
    required this.usedComponents,
    required this.totalInvoices,
    required this.statusMetrics,
    required this.incomeChart,
    required this.resourceMetrics,
    required this.criticalLogs,
    this.errorMessage,
  });

  factory DashboardState.initial() {
    return DashboardState(
      rangeIndex: 1,
      totalIncome: 0,
      incomeDelta: '0%',
      inventoryTurnover: 0,
      efficiency: 0,
      monthlyIncome: 0,
      averageInvoiceValue: 0,
      totalDevices: 0,
      totalEngineering: 0,
      activeEngineering: 0,
      inactiveEngineering: 0,
      totalComponents: 0,
      usedComponents: 0,
      totalInvoices: 0,
      statusMetrics: const [
        DashboardStatusMetric(
          status: DashboardDeviceStatus.received,
          value: 0,
          color: Colors.blue,
        ),
        DashboardStatusMetric(
          status: DashboardDeviceStatus.waiting,
          value: 0,
          color: Colors.amber,
        ),
        DashboardStatusMetric(
          status: DashboardDeviceStatus.inMaintenance,
          value: 0,
          color: Colors.purple,
        ),
        DashboardStatusMetric(
          status: DashboardDeviceStatus.completed,
          value: 0,
          color: Colors.green,
        ),
        DashboardStatusMetric(
          status: DashboardDeviceStatus.delivered,
          value: 0,
          color: Colors.teal,
        ),
      ],
      incomeChart: const [],
      resourceMetrics: const [
        DashboardResourceMetric(
          type: DashboardResourceType.active,
          value: 0,
          color: Colors.green,
        ),
        DashboardResourceMetric(
          type: DashboardResourceType.onLeave,
          value: 0,
          color: Colors.orange,
        ),
        DashboardResourceMetric(
          type: DashboardResourceType.available,
          value: 0,
          color: Colors.grey,
        ),
      ],
      criticalLogs: const [],
    );
  }

  DashboardState copyWith({
    int? rangeIndex,
    bool? isLoading,
    double? totalIncome,
    String? incomeDelta,
    double? inventoryTurnover,
    double? efficiency,
    double? monthlyIncome,
    double? averageInvoiceValue,
    int? totalDevices,
    int? totalEngineering,
    int? activeEngineering,
    int? inactiveEngineering,
    int? totalComponents,
    int? usedComponents,
    int? totalInvoices,
    List<DashboardStatusMetric>? statusMetrics,
    List<DashboardIncomePoint>? incomeChart,
    List<DashboardResourceMetric>? resourceMetrics,
    List<DashboardLogEntry>? criticalLogs,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DashboardState(
      rangeIndex: rangeIndex ?? this.rangeIndex,
      isLoading: isLoading ?? this.isLoading,
      totalIncome: totalIncome ?? this.totalIncome,
      incomeDelta: incomeDelta ?? this.incomeDelta,
      inventoryTurnover: inventoryTurnover ?? this.inventoryTurnover,
      efficiency: efficiency ?? this.efficiency,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      averageInvoiceValue: averageInvoiceValue ?? this.averageInvoiceValue,
      totalDevices: totalDevices ?? this.totalDevices,
      totalEngineering: totalEngineering ?? this.totalEngineering,
      activeEngineering: activeEngineering ?? this.activeEngineering,
      inactiveEngineering: inactiveEngineering ?? this.inactiveEngineering,
      totalComponents: totalComponents ?? this.totalComponents,
      usedComponents: usedComponents ?? this.usedComponents,
      totalInvoices: totalInvoices ?? this.totalInvoices,
      statusMetrics: statusMetrics ?? this.statusMetrics,
      incomeChart: incomeChart ?? this.incomeChart,
      resourceMetrics: resourceMetrics ?? this.resourceMetrics,
      criticalLogs: criticalLogs ?? this.criticalLogs,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    rangeIndex,
    isLoading,
    totalIncome,
    incomeDelta,
    inventoryTurnover,
    efficiency,
    monthlyIncome,
    averageInvoiceValue,
    totalDevices,
    totalEngineering,
    activeEngineering,
    inactiveEngineering,
    totalComponents,
    usedComponents,
    totalInvoices,
    statusMetrics,
    incomeChart,
    resourceMetrics,
    criticalLogs,
    errorMessage,
  ];
}

class DashboardCubit extends Cubit<DashboardState> {
  final AppHttpClient client;
  final Uri baseUri;

  DashboardCubit(this.client, {Uri? baseUri})
    : baseUri =
          baseUri ??
          Uri.parse('http://al-mumtazun-api.runasp.net/api/Dashboard'),
      super(DashboardState.initial());

  Future<void> setRangeIndex(int index) {
    emit(state.copyWith(rangeIndex: index));
    return fetch();
  }

  Future<void> refresh() => fetch();

  Future<void> fetch() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final response = await client.get(
        baseUri.replace(
          queryParameters: {'range': _rangeValue(state.rangeIndex)},
        ),
        headers: {'accept': 'text/plain'},
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(_errorMessage(response.statusCode, response.body));
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Unexpected dashboard response format');
      }

      emit(
        _stateFromJson(decoded).copyWith(isLoading: false, clearError: true),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  DashboardState _stateFromJson(Map<String, dynamic> json) {
    final totalEngineers = _readInt(json['totalEngineers']);
    final activeEngineers = _readInt(json['activeEngineers']);
    final inactiveEngineers = _readInt(
      json['inactiveEngineers'],
      totalEngineers - activeEngineers,
    );
    final totalSpareParts = _readInt(json['totalSpareParts']);
    final usedSpareParts = _readInt(json['usedSpareParts']);

    return state.copyWith(
      totalIncome: _readDouble(json['totalIncome']),
      monthlyIncome: _readDouble(json['monthlyIncome']),
      incomeDelta: _formatGrowth(_readDouble(json['incomeGrowthPercentage'])),
      averageInvoiceValue: _readDouble(json['averageInvoiceValue']),
      totalDevices: _readInt(json['totalDevices']),
      inventoryTurnover: _readDouble(json['inventoryTurnoverRate']),
      efficiency: (_readDouble(json['efficiencyRate']) / 100).clamp(0, 1),
      totalEngineering: totalEngineers,
      activeEngineering: activeEngineers,
      inactiveEngineering: inactiveEngineers,
      totalComponents: totalSpareParts,
      usedComponents: usedSpareParts,
      totalInvoices: _readInt(json['totalInvoices']),
      statusMetrics: _statusMetricsFromJson(json),
      incomeChart: _incomeChartFromJson(json['incomeChart']),
      resourceMetrics: _resourceMetrics(
        totalEngineers: totalEngineers,
        activeEngineers: activeEngineers,
        inactiveEngineers: inactiveEngineers,
      ),
      criticalLogs: _logsFromJson(json['criticalLogs']),
    );
  }

  List<DashboardStatusMetric> _statusMetricsFromJson(
    Map<String, dynamic> json,
  ) {
    final raw = json['statusMetrics'];
    final byStatus = <DashboardDeviceStatus, double>{};

    if (raw is List) {
      for (final item in raw.whereType<Map<String, dynamic>>()) {
        byStatus[_statusFromString(item['status']?.toString())] = _readDouble(
          item['value'],
        );
      }
    }

    return [
      DashboardStatusMetric(
        status: DashboardDeviceStatus.received,
        value:
            byStatus[DashboardDeviceStatus.received] ??
            _readDouble(json['receivedDevices']),
        color: Colors.blue,
      ),
      DashboardStatusMetric(
        status: DashboardDeviceStatus.waiting,
        value:
            byStatus[DashboardDeviceStatus.waiting] ??
            _readDouble(json['waitingDevices']),
        color: Colors.amber,
      ),
      DashboardStatusMetric(
        status: DashboardDeviceStatus.inMaintenance,
        value:
            byStatus[DashboardDeviceStatus.inMaintenance] ??
            _readDouble(json['inMaintenanceDevices']),
        color: Colors.purple,
      ),
      DashboardStatusMetric(
        status: DashboardDeviceStatus.completed,
        value:
            byStatus[DashboardDeviceStatus.completed] ??
            _readDouble(json['completedDevices']),
        color: Colors.green,
      ),
      DashboardStatusMetric(
        status: DashboardDeviceStatus.delivered,
        value:
            byStatus[DashboardDeviceStatus.delivered] ??
            _readDouble(json['deliveredDevices']),
        color: Colors.teal,
      ),
    ];
  }

  List<DashboardResourceMetric> _resourceMetrics({
    required int totalEngineers,
    required int activeEngineers,
    required int inactiveEngineers,
  }) {
    final total = totalEngineers == 0 ? 1 : totalEngineers;
    return [
      DashboardResourceMetric(
        type: DashboardResourceType.active,
        value: (activeEngineers / total).clamp(0, 1),
        color: Colors.green,
      ),
      DashboardResourceMetric(
        type: DashboardResourceType.onLeave,
        value: (inactiveEngineers / total).clamp(0, 1),
        color: Colors.orange,
      ),
      DashboardResourceMetric(
        type: DashboardResourceType.available,
        value: totalEngineers == 0 ? 1 : 0,
        color: Colors.grey,
      ),
    ];
  }

  List<DashboardLogEntry> _logsFromJson(dynamic value) {
    if (value is! List) return const [];

    return value.whereType<Map<String, dynamic>>().map((json) {
      final status = _statusFromString(json['type']?.toString());
      final logType = _logTypeForStatus(status);
      return DashboardLogEntry(
        type: logType,
        title: json['title']?.toString() ?? '',
        subtitle: json['subtitle']?.toString() ?? '',
        date: DateTime.tryParse(json['date']?.toString() ?? ''),
        icon: _iconForLogType(logType),
        color: _colorForStatus(status),
      );
    }).toList();
  }

  List<DashboardIncomePoint> _incomeChartFromJson(dynamic value) {
    if (value is! List) return const [];

    return value.whereType<Map<String, dynamic>>().map((json) {
      return DashboardIncomePoint(
        label: json['label']?.toString() ?? '',
        value: _readDouble(json['value']),
      );
    }).toList();
  }

  DashboardDeviceStatus _statusFromString(String? value) {
    final normalized = value?.replaceAll('_', '').toLowerCase();
    return switch (normalized) {
      'received' => DashboardDeviceStatus.received,
      'waiting' => DashboardDeviceStatus.waiting,
      'inmaintenance' => DashboardDeviceStatus.inMaintenance,
      'completed' => DashboardDeviceStatus.completed,
      'delivered' => DashboardDeviceStatus.delivered,
      _ => DashboardDeviceStatus.waiting,
    };
  }

  DashboardLogType _logTypeForStatus(DashboardDeviceStatus status) {
    return switch (status) {
      DashboardDeviceStatus.received ||
      DashboardDeviceStatus.waiting ||
      DashboardDeviceStatus.inMaintenance => DashboardLogType.deviceOverheating,
      DashboardDeviceStatus.completed => DashboardLogType.repairCompleted,
      DashboardDeviceStatus.delivered => DashboardLogType.lowStock,
    };
  }

  IconData _iconForLogType(DashboardLogType type) {
    return switch (type) {
      DashboardLogType.deviceOverheating => Icons.warning,
      DashboardLogType.lowStock => Icons.inventory,
      DashboardLogType.repairCompleted => Icons.check_circle,
    };
  }

  Color _colorForStatus(DashboardDeviceStatus status) {
    return switch (status) {
      DashboardDeviceStatus.received => Colors.blue,
      DashboardDeviceStatus.waiting => Colors.amber,
      DashboardDeviceStatus.inMaintenance => Colors.purple,
      DashboardDeviceStatus.completed => Colors.green,
      DashboardDeviceStatus.delivered => Colors.teal,
    };
  }

  String _rangeValue(int index) {
    return switch (index) {
      0 => 'week',
      2 => 'year',
      _ => 'month',
    };
  }

  String _formatGrowth(double value) {
    final prefix = value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(1)}%';
  }

  int _readInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  double _readDouble(dynamic value, [double fallback = 0]) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  String _errorMessage(int statusCode, String body) {
    final trimmed = body.trim();
    return trimmed.isEmpty
        ? 'Dashboard request failed: HTTP $statusCode'
        : 'Dashboard request failed: HTTP $statusCode: $trimmed';
  }
}
