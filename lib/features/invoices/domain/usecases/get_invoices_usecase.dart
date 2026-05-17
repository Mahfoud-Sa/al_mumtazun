import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/invoice_page.dart';
import '../repositories/invoice_repository.dart';

class GetInvoicesUseCase implements UseCase<InvoicePage, GetInvoicesParams> {
  final InvoiceRepository repository;

  GetInvoicesUseCase(this.repository);

  @override
  Future<Either<Failure, InvoicePage>> call(GetInvoicesParams params) {
    return repository.getInvoices(page: params.page, size: params.size);
  }
}

class GetInvoicesParams {
  final int page;
  final int size;

  const GetInvoicesParams({required this.page, required this.size});
}
