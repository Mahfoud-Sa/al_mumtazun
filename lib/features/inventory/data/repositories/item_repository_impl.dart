import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/item.dart';
import '../../domain/repositories/item_repository.dart';
import '../datasources/inventory_local_datasource.dart';
import '../models/item_model.dart';

class ItemRepositoryImpl implements ItemRepository {
  final InventoryLocalDataSource local;

  ItemRepositoryImpl(this.local);

  @override
  Future<Either<Failure, Item>> create(Item item) async {
    try {
      final list = await local.getItems();
      final model = ItemModel(id: item.id, name: item.name, description: item.description, quantity: item.quantity);
      list.add(model);
      await local.saveItems(list);
      return Right(model);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> delete(String id) async {
    try {
      final list = await local.getItems();
      list.removeWhere((i) => i.id == id);
      await local.saveItems(list);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Item>>> getAll() async {
    try {
      final list = await local.getItems();
      return Right(list);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Item>> getById(String id) async {
    try {
      final list = await local.getItems();
      final it = list.firstWhere((i) => i.id == id);
      return Right(it);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Item>> update(Item item) async {
    try {
      final list = await local.getItems();
      final idx = list.indexWhere((i) => i.id == item.id);
      final model = ItemModel(id: item.id, name: item.name, description: item.description, quantity: item.quantity);
      if (idx >= 0) list[idx] = model;
      await local.saveItems(list);
      return Right(model);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
