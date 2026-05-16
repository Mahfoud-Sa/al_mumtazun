import '../../domain/entities/device.dart';

class DeviceModel extends Device {
  const DeviceModel({
    required super.id,
    required super.name,
    required super.serialNumber,
    required super.brand,
    required super.model,
    required super.customerName,
    required super.phoneNumbers,
    required super.receivedBy,
    required super.status,
    required super.problemDescription,
    required super.internalNotes,
    required super.createdAt,
  });

  factory DeviceModel.fromEntity(Device device) {
    return DeviceModel(
      id: device.id,
      name: device.name,
      serialNumber: device.serialNumber,
      brand: device.brand,
      model: device.model,
      customerName: device.customerName,
      phoneNumbers: device.phoneNumbers,
      receivedBy: device.receivedBy,
      status: device.status,
      problemDescription: device.problemDescription,
      internalNotes: device.internalNotes,
      createdAt: device.createdAt,
    );
  }

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    final receivedDate = json['receivedDate'] ?? json['createdAt'];
    final deviceName = json['deviceName'] ?? json['name'];
    final receivedBy = json['receivedByUserName'] ?? json['receivedBy'];
    return DeviceModel(
      id: json['id']?.toString() ?? '',
      name: deviceName?.toString() ?? '',
      serialNumber:
          json['serialNumber']?.toString() ??
          json['serial']?.toString() ??
          '#${json['id'] ?? 'N/A'}',
      brand: json['brand']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      phoneNumbers: (json['phoneNumbers'] as List<dynamic>? ?? const [])
          .map((phone) => phone.toString())
          .toList(),
      receivedBy: receivedBy?.toString() ?? '',
      status: _statusFromJson(json['status']?.toString()),
      problemDescription: json['problemDescription']?.toString() ?? '',
      internalNotes:
          json['notes']?.toString() ?? json['internalNotes']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(receivedDate?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'serialNumber': serialNumber,
      'brand': brand,
      'model': model,
      'customerName': customerName,
      'phoneNumbers': phoneNumbers,
      'receivedBy': receivedBy,
      'status': status.name,
      'problemDescription': problemDescription,
      'internalNotes': internalNotes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'customerName': customerName,
      'receivedByUserName': receivedBy,
      'deviceName': name,
      'brand': brand,
      'model': model,
      'problemDescription': problemDescription,
      'notes': internalNotes,
      'status': _statusToApi(status),
      'receivedDate': createdAt.toUtc().toIso8601String(),
      'expectedCost': 0,
      'finalCost': 0,
    };
  }

  static DeviceStatus _statusFromJson(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == 'inrepair' ||
        normalized == 'in repair' ||
        normalized == 'قيد الصيانة') {
      return DeviceStatus.inRepair;
    }
    if (normalized == 'completed' || normalized == 'مكتمل') {
      return DeviceStatus.completed;
    }
    return DeviceStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => DeviceStatus.pending,
    );
  }

  static String _statusToApi(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.inRepair:
        return 'InRepair';
      case DeviceStatus.pending:
        return 'Pending';
      case DeviceStatus.completed:
        return 'Completed';
    }
  }
}
