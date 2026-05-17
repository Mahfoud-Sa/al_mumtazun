import '../../../devices/data/models/device_model.dart';
import '../../domain/entities/invoice.dart';
import 'invoice_item_model.dart';

class InvoiceModel extends Invoice {
  const InvoiceModel({
    required super.id,
    required super.deviceId,
    required super.device,
    required super.customerId,
    required super.date,
    required super.discount,
    required super.items,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    final device = json['device'];
    final items = json['items'];

    return InvoiceModel(
      id: _readInt(json['id'], 0),
      deviceId: _readInt(json['deviceId'], 0),
      device: device is Map<String, dynamic>
          ? DeviceModel.fromJson(device)
          : null,
      customerId: _readInt(json['customerId'], 0),
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      discount: _readDouble(json['discount'], 0),
      items: items is List
          ? items
                .whereType<Map<String, dynamic>>()
                .map(InvoiceItemModel.fromJson)
                .toList()
          : const [],
    );
  }

  static int _readInt(dynamic value, int fallback) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static double _readDouble(dynamic value, double fallback) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
