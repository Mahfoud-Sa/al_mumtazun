import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

class DashboardLogEntry extends Equatable {
  final DashboardLogType type;
  final IconData icon;
  final Color color;

  const DashboardLogEntry({
    required this.type,
    required this.icon,
    required this.color,
  });

  @override
  List<Object?> get props => [type, icon, color];
}

class DashboardState extends Equatable {
  final int rangeIndex;
  final bool isLoading;
  final double totalIncome;
  final String incomeDelta;
  final double inventoryTurnover;
  final double efficiency;
  final int totalEngineering;
  final int totalComponents;
  final int totalInvoices;
  final List<DashboardStatusMetric> statusMetrics;
  final List<DashboardResourceMetric> resourceMetrics;
  final List<DashboardLogEntry> criticalLogs;

  const DashboardState({
    required this.rangeIndex,
    this.isLoading = false,
    required this.totalIncome,
    required this.incomeDelta,
    required this.inventoryTurnover,
    required this.efficiency,
    required this.totalEngineering,
    required this.totalComponents,
    required this.totalInvoices,
    required this.statusMetrics,
    required this.resourceMetrics,
    required this.criticalLogs,
  });

  factory DashboardState.initial() {
    return const DashboardState(
      rangeIndex: 1,
      totalIncome: 1248392.50,
      incomeDelta: '+12.4%',
      inventoryTurnover: 4.8,
      efficiency: 0.92,
      totalEngineering: 128,
      totalComponents: 542,
      totalInvoices: 87,
      statusMetrics: [
        DashboardStatusMetric(
          status: DashboardDeviceStatus.received,
          value: 30,
          color: Colors.blue,
        ),
        DashboardStatusMetric(
          status: DashboardDeviceStatus.waiting,
          value: 20,
          color: Colors.amber,
        ),
        DashboardStatusMetric(
          status: DashboardDeviceStatus.inMaintenance,
          value: 25,
          color: Colors.purple,
        ),
        DashboardStatusMetric(
          status: DashboardDeviceStatus.completed,
          value: 40,
          color: Colors.green,
        ),
        DashboardStatusMetric(
          status: DashboardDeviceStatus.delivered,
          value: 13,
          color: Colors.teal,
        ),
      ],
      resourceMetrics: [
        DashboardResourceMetric(
          type: DashboardResourceType.active,
          value: 0.7,
          color: Colors.green,
        ),
        DashboardResourceMetric(
          type: DashboardResourceType.onLeave,
          value: 0.2,
          color: Colors.orange,
        ),
        DashboardResourceMetric(
          type: DashboardResourceType.available,
          value: 0.1,
          color: Colors.grey,
        ),
      ],
      criticalLogs: [
        DashboardLogEntry(
          type: DashboardLogType.deviceOverheating,
          icon: Icons.warning,
          color: Colors.red,
        ),
        DashboardLogEntry(
          type: DashboardLogType.lowStock,
          icon: Icons.inventory,
          color: Colors.orange,
        ),
        DashboardLogEntry(
          type: DashboardLogType.repairCompleted,
          icon: Icons.check_circle,
          color: Colors.green,
        ),
      ],
    );
  }

  DashboardState copyWith({int? rangeIndex, bool? isLoading}) {
    return DashboardState(
      rangeIndex: rangeIndex ?? this.rangeIndex,
      isLoading: isLoading ?? this.isLoading,
      totalIncome: totalIncome,
      incomeDelta: incomeDelta,
      inventoryTurnover: inventoryTurnover,
      efficiency: efficiency,
      totalEngineering: totalEngineering,
      totalComponents: totalComponents,
      totalInvoices: totalInvoices,
      statusMetrics: statusMetrics,
      resourceMetrics: resourceMetrics,
      criticalLogs: criticalLogs,
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
    totalEngineering,
    totalComponents,
    totalInvoices,
    statusMetrics,
    resourceMetrics,
    criticalLogs,
  ];
}

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(DashboardState.initial());

  void setRangeIndex(int index) {
    emit(state.copyWith(rangeIndex: index));
  }

  Future<void> refresh() async {
    emit(state.copyWith(isLoading: true));
    emit(state.copyWith(isLoading: false));
  }
}
