import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/invoice.dart';
import '../entities/invoice_page.dart';

abstract class InvoiceRepository {
  Future<Either<Failure, Invoice?>> getInvoiceByDeviceId(int deviceId);
  Future<Either<Failure, Invoice>> createInvoice(Invoice invoice);
  Future<Either<Failure, Invoice>> updateInvoice({
    required int id,
    required Invoice invoice,
  });
  Future<Either<Failure, InvoicePage>> getInvoices({
    required int page,
    required int size,
  });
}
