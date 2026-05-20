import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/item.dart';
import '../repositories/item_repository.dart';

class GetItemsUseCase implements UseCase<List<Item>, NoParams> {
  final ItemRepository repository;
  GetItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Item>>> call(NoParams params) async {
    return repository.getAll();
  }
}

class CreateItemUseCase implements UseCase<Item, Item> {
  final ItemRepository repository;
  CreateItemUseCase(this.repository);

  @override
  Future<Either<Failure, Item>> call(Item params) async =>
      repository.create(params);
}

class UpdateItemUseCase implements UseCase<Item, Item> {
  final ItemRepository repository;
  UpdateItemUseCase(this.repository);

  @override
  Future<Either<Failure, Item>> call(Item params) async =>
      repository.update(params);
}

class DeleteItemUseCase implements UseCase<bool, String> {
  final ItemRepository repository;
  DeleteItemUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String params) async =>
      repository.delete(params);
}
