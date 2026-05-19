import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/invoice_repository.dart';

class DeleteInvoiceUseCase {
  final InvoiceRepository repository;

  DeleteInvoiceUseCase(this.repository);

  Future<Either<Failure, void>> call(DeleteInvoiceParams params) {
    return repository.deleteInvoice(params.id);
  }
}

class DeleteInvoiceParams {
  final int id;

  const DeleteInvoiceParams({required this.id});
}
