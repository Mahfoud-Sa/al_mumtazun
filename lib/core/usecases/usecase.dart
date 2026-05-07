import 'package:dartz/dartz.dart' as dartz;
import '../errors/failures.dart';

/// Generic UseCase signature: returns Either<Failure, R>
abstract class UseCase<R, Params> {
  Future<dartz.Either<Failure, R>> call(Params params);
}

class NoParams {}
