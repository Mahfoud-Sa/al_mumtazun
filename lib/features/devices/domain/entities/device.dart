import 'package:equatable/equatable.dart';

enum DeviceStatus { received, waiting, inMaintenance, ready, delivered }

class Device extends Equatable {
  final String id;
  final String name;
  final String serialNumber;
  final String brand;
  final String model;
  final String customerName;
  final List<String> phoneNumbers;
  final String receivedBy;
  final DeviceStatus status;
  final String problemDescription;
  final String internalNotes;
  final String engineerNote;
  final DateTime createdAt;

  const Device({
    required this.id,
    required this.name,
    required this.serialNumber,
    required this.brand,
    required this.model,
    required this.customerName,
    required this.phoneNumbers,
    required this.receivedBy,
    required this.status,
    required this.problemDescription,
    required this.internalNotes,
    this.engineerNote = '',
    required this.createdAt,
  });

  Device copyWith({
    String? id,
    String? name,
    String? serialNumber,
    String? brand,
    String? model,
    String? customerName,
    List<String>? phoneNumbers,
    String? receivedBy,
    DeviceStatus? status,
    String? problemDescription,
    String? internalNotes,
    String? engineerNote,
    DateTime? createdAt,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      serialNumber: serialNumber ?? this.serialNumber,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      customerName: customerName ?? this.customerName,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      receivedBy: receivedBy ?? this.receivedBy,
      status: status ?? this.status,
      problemDescription: problemDescription ?? this.problemDescription,
      internalNotes: internalNotes ?? this.internalNotes,
      engineerNote: engineerNote ?? this.engineerNote,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    serialNumber,
    brand,
    model,
    customerName,
    phoneNumbers,
    receivedBy,
    status,
    problemDescription,
    internalNotes,
    engineerNote,
    createdAt,
  ];
}
