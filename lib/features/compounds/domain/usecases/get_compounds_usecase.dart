import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/compound_page.dart';
import '../repositories/compound_repository.dart';

class GetCompoundsUseCase implements UseCase<CompoundPage, GetCompoundsParams> {
  final CompoundRepository repository;

  GetCompoundsUseCase(this.repository);

  @override
  Future<Either<Failure, CompoundPage>> call(GetCompoundsParams params) {
    return repository.getAll(page: params.page, size: params.size);
  }
}

class GetCompoundsParams {
  final int page;
  final int size;

  const GetCompoundsParams({required this.page, required this.size});
}
