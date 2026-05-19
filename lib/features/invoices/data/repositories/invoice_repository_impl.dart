import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_page.dart';
import '../../domain/entities/invoice_query.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../datasources/invoices_remote_datasource.dart';
import '../models/invoice_model.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoicesRemoteDataSource remote;

  InvoiceRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, Invoice?>> getInvoiceByDeviceId(int deviceId) async {
    try {
      final invoice = await remote.getInvoiceByDeviceId(deviceId);
      return Right(invoice);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, Invoice>> createInvoice(Invoice invoice) async {
    try {
      final created = await remote.createInvoice(
        InvoiceModel.fromEntity(invoice),
      );
      return Right(created);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, Invoice>> updateInvoice({
    required int id,
    required Invoice invoice,
  }) async {
    try {
      final updated = await remote.updateInvoice(
        id,
        InvoiceModel.fromEntity(invoice),
      );
      return Right(updated);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteInvoice(int id) async {
    try {
      await remote.deleteInvoice(id);
      return const Right(null);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, InvoicePage>> getInvoices({
    required InvoiceQuery query,
  }) async {
    try {
      final invoicesPage = await remote.getInvoices(query: query);
      return Right(invoicesPage);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }
}
