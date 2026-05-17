import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/invoice_page.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../datasources/invoices_remote_datasource.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoicesRemoteDataSource remote;

  InvoiceRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, InvoicePage>> getInvoices({
    required int page,
    required int size,
  }) async {
    try {
      final invoicesPage = await remote.getInvoices(page: page, size: size);
      return Right(invoicesPage);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }
}
