import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/invoice_page.dart';
import '../entities/invoice_query.dart';
import '../repositories/invoice_repository.dart';

class GetInvoicesUseCase implements UseCase<InvoicePage, GetInvoicesParams> {
  final InvoiceRepository repository;

  GetInvoicesUseCase(this.repository);

  @override
  Future<Either<Failure, InvoicePage>> call(GetInvoicesParams params) {
    return repository.getInvoices(query: params.query);
  }
}

class GetInvoicesParams {
  final InvoiceQuery query;

  const GetInvoicesParams({required this.query});
}
