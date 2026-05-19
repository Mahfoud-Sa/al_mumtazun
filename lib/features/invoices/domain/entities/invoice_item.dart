import 'package:equatable/equatable.dart';

class InvoiceItem extends Equatable {
  final int id;
  final int invoiceId;
  final int? sparePartId;
  final String sparePartName;
  final int quantity;
  final double unitPrice;
  final double? responseTotal;

  const InvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.sparePartId,
    required this.sparePartName,
    required this.quantity,
    required this.unitPrice,
    this.responseTotal,
  });

  InvoiceItem copyWith({
    int? id,
    int? invoiceId,
    int? sparePartId,
    String? sparePartName,
    int? quantity,
    double? unitPrice,
    double? responseTotal,
    bool clearResponseTotal = false,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      sparePartId: sparePartId ?? this.sparePartId,
      sparePartName: sparePartName ?? this.sparePartName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      responseTotal: clearResponseTotal
          ? null
          : responseTotal ?? this.responseTotal,
    );
  }

  double get total => responseTotal ?? quantity * unitPrice;

  @override
  List<Object?> get props => [
    id,
    invoiceId,
    sparePartId,
    sparePartName,
    quantity,
    unitPrice,
    responseTotal,
  ];
}
