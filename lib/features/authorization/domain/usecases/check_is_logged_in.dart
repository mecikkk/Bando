import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/authorization/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class CheckIsLoggedIn {
  final AuthRepository _repository;

  CheckIsLoggedIn(this._repository);

  Future<Either<Failure, User>> call() async {
    return await _repository.isLoggedIn();
  }
}
