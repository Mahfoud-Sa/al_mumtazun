import '../../domain/entities/device.dart';

class DeviceModel extends Device {
  const DeviceModel({
    required super.id,
    required super.name,
    required super.brand,
    required super.model,
    required super.customerName,
    required super.phoneNumbers,
    required super.receivedBy,
    required super.status,
    required super.problemDescription,
    required super.internalNotes,
    super.engineerNote,
    required super.createdAt,
  });

  factory DeviceModel.fromEntity(Device device) {
    return DeviceModel(
      id: device.id,
      name: device.name,
      brand: device.brand,
      model: device.model,
      customerName: device.customerName,
      phoneNumbers: device.phoneNumbers,
      receivedBy: device.receivedBy,
      status: device.status,
      problemDescription: device.problemDescription,
      internalNotes: device.internalNotes,
      engineerNote: device.engineerNote,
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
      engineerNote: json['engineerNote']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(receivedDate?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'model': model,
      'customerName': customerName,
      'phoneNumbers': phoneNumbers,
      'receivedBy': receivedBy,
      'status': status.name,
      'problemDescription': problemDescription,
      'internalNotes': internalNotes,
      'engineerNote': engineerNote,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'customerName': customerName,
      'receivedByUserName': receivedBy,
      'deviceName': name,
      'engineerNote': engineerNote,
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

  Map<String, dynamic> toUpdateJson() {
    return {
      'customerName': customerName,
      'receivedByUserName': receivedBy,
      'deviceName': name,
      'engineerNote': engineerNote,
      'brand': brand,
      'model': model,
      'problemDescription': problemDescription,
      'notes': internalNotes,
      'receivedDate': createdAt.toUtc().toIso8601String(),
      'expectedCost': 0,
      'finalCost': 0,
    };
  }

  static DeviceStatus _statusFromJson(String? value) {
    final normalized = value?.trim().toLowerCase();
    final apiIndex = int.tryParse(normalized ?? '');
    if (apiIndex != null &&
        apiIndex >= 0 &&
        apiIndex < DeviceStatus.values.length) {
      return DeviceStatus.values[apiIndex];
    }

    switch (normalized) {
      case 'received':
        return DeviceStatus.received;
      case 'waiting':
      case 'pending':
        return DeviceStatus.waiting;
      case 'inmaintenance':
      case 'in maintenance':
      case 'inrepair':
      case 'in repair':
        return DeviceStatus.inMaintenance;
      case 'completed':
        return DeviceStatus.ready;
      case 'delivered':
        return DeviceStatus.delivered;
    }

    return DeviceStatus.values.firstWhere(
      (status) => status.name.toLowerCase() == normalized,
      orElse: () => DeviceStatus.received,
    );
  }

  static int statusToApiValue(DeviceStatus status) {
    return status.index;
  }

  static String _statusToApi(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.received:
        return 'Received';
      case DeviceStatus.waiting:
        return 'Waiting';
      case DeviceStatus.inMaintenance:
        return 'InMaintenance';
      case DeviceStatus.ready:
        return 'Completed';
      case DeviceStatus.delivered:
        return 'Delivered';
    }
  }
}
