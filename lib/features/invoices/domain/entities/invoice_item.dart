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
