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
    return repository.getAll(
      page: params.page,
      size: params.size,
      search: params.search,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      sortBy: params.sortBy,
      sortDirection: params.sortDirection,
    );
  }
}

class GetCompoundsParams {
  final int page;
  final int size;
  final String? search;
  final double? minPrice;
  final double? maxPrice;
  final String? sortBy;
  final String? sortDirection;

  const GetCompoundsParams({
    required this.page,
    required this.size,
    this.search,
    this.minPrice,
    this.maxPrice,
    this.sortBy,
    this.sortDirection,
  });
}
