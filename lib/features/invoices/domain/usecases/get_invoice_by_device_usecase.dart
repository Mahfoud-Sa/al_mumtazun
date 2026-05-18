import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/invoice.dart';
import '../repositories/invoice_repository.dart';

class GetInvoiceByDeviceUseCase {
  final InvoiceRepository repository;

  GetInvoiceByDeviceUseCase(this.repository);

  Future<Either<Failure, Invoice?>> call(GetInvoiceByDeviceParams params) {
    return repository.getInvoiceByDeviceId(params.deviceId);
  }
}

class GetInvoiceByDeviceParams {
  final int deviceId;

  const GetInvoiceByDeviceParams({required this.deviceId});
}
