import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/authorization/domain/repositories/login_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

class SignInWithEmailAndPasswordUseCase {
  final LoginRepository _loginRepository;

  SignInWithEmailAndPasswordUseCase(this._loginRepository);

  Future<Either<Failure, User>> call({@required EmailAddress email, @required Password password}) async {
    return await _loginRepository.signInWithEmailAndPassword(email, password);
  }
}
