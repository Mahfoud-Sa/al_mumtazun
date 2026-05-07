import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/item.dart';

abstract class ItemRepository {
  Future<Either<Failure, Item>> create(Item item);
  Future<Either<Failure, List<Item>>> getAll();
  Future<Either<Failure, Item>> getById(String id);
  Future<Either<Failure, Item>> update(Item item);
  Future<Either<Failure, bool>> delete(String id);
}
