import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/authorization/data/repositories/auth_repository_impl.dart';
import 'package:dartz/dartz.dart';

class RegisterWithEmailAndPassword {
  final AuthRepositoryImpl _repository;

  RegisterWithEmailAndPassword(this._repository);

  Future<Either<Failure, User>> call(EmailAddress email, Password password, String username) async {
    return await _repository.registerWithEmailAndPassword(email, password, username);
  }
}
