import 'package:equatable/equatable.dart';

class InvoiceItem extends Equatable {
  final int id;
  final int invoiceId;
  final int? sparePartId;
  final String sparePartName;
  final int quantity;
  final double unitPrice;

  const InvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.sparePartId,
    required this.sparePartName,
    required this.quantity,
    required this.unitPrice,
  });

  InvoiceItem copyWith({
    int? id,
    int? invoiceId,
    int? sparePartId,
    String? sparePartName,
    int? quantity,
    double? unitPrice,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      sparePartId: sparePartId ?? this.sparePartId,
      sparePartName: sparePartName ?? this.sparePartName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  double get total => quantity * unitPrice;

  @override
  List<Object?> get props => [
    id,
    invoiceId,
    sparePartId,
    sparePartName,
    quantity,
    unitPrice,
  ];
}
