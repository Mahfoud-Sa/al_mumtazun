import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/invoice.dart';
import '../repositories/invoice_repository.dart';

class UpdateInvoiceUseCase {
  final InvoiceRepository repository;

  UpdateInvoiceUseCase(this.repository);

  Future<Either<Failure, Invoice>> call(UpdateInvoiceParams params) {
    return repository.updateInvoice(id: params.id, invoice: params.invoice);
  }
}

class UpdateInvoiceParams {
  final int id;
  final Invoice invoice;

  const UpdateInvoiceParams({required this.id, required this.invoice});
}
