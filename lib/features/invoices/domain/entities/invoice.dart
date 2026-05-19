import 'package:equatable/equatable.dart';

import '../../../devices/domain/entities/device.dart';
import 'invoice_item.dart';

class Invoice extends Equatable {
  final int id;
  final int deviceId;
  final Device? device;
  final int customerId;
  final DateTime date;
  final double discount;
  final double? responseSubTotal;
  final double? responseTotal;
  final List<InvoiceItem> items;

  const Invoice({
    required this.id,
    required this.deviceId,
    required this.device,
    required this.customerId,
    required this.date,
    required this.discount,
    this.responseSubTotal,
    this.responseTotal,
    required this.items,
  });

  double get subTotal =>
      responseSubTotal ?? items.fold(0, (sum, item) => sum + item.total);

  double get total {
    if (responseTotal != null) return responseTotal!;
    final value = subTotal - discount;
    return value < 0 ? 0 : value;
  }

  @override
  List<Object?> get props => [
    id,
    deviceId,
    device,
    customerId,
    date,
    discount,
    responseSubTotal,
    responseTotal,
    items,
  ];
}
