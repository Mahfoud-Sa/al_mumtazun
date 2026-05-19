import '../../domain/entities/invoice_item.dart';

class InvoiceItemModel extends InvoiceItem {
  const InvoiceItemModel({
    required super.id,
    required super.invoiceId,
    required super.sparePartId,
    required super.sparePartName,
    required super.quantity,
    required super.unitPrice,
    super.responseTotal,
  });

  factory InvoiceItemModel.fromEntity(InvoiceItem item) {
    return InvoiceItemModel(
      id: item.id,
      invoiceId: item.invoiceId,
      sparePartId: item.sparePartId,
      sparePartName: item.sparePartName,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      responseTotal: item.responseTotal,
    );
  }

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    final sparePart = json['sparePart'];
    final sparePartName = sparePart is Map<String, dynamic>
        ? sparePart['name']?.toString() ??
              sparePart['partName']?.toString() ??
              sparePart['deviceName']?.toString() ??
              ''
        : json['sparePartName']?.toString() ?? '';

    return InvoiceItemModel(
      id: _readInt(json['id'] ?? json['invoiceItemId'], 0),
      invoiceId: _readInt(json['invoiceId'], 0),
      sparePartId: _readNullableInt(json['sparePartId']),
      sparePartName: sparePartName,
      quantity: _readInt(json['quantity'], 0),
      unitPrice: _readDouble(json['unitPrice'] ?? json['price'], 0),
      responseTotal: _readNullableDouble(json['total']),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'sparePartId': sparePartId ?? 0,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  static int _readInt(dynamic value, int fallback) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static int? _readNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double _readDouble(dynamic value, double fallback) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static double? _readNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
