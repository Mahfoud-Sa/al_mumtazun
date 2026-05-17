import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/invoice.dart';
import '../repositories/invoice_repository.dart';

class CreateInvoiceUseCase {
  final InvoiceRepository repository;

  CreateInvoiceUseCase(this.repository);

  Future<Either<Failure, Invoice>> call(CreateInvoiceParams params) {
    return repository.createInvoice(params.invoice);
  }
}

class CreateInvoiceParams {
  final Invoice invoice;

  const CreateInvoiceParams({required this.invoice});
}
