import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/authorization/data/repositories/auth_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

class SignInWithEmailAndPassword {
  final AuthRepositoryImpl _authRepository;

  SignInWithEmailAndPassword(this._authRepository);

  Future<Either<Failure, User>> call({@required EmailAddress email, @required Password password}) async {
    return await _authRepository.signInWithEmailAndPassword(email, password);
  }
}
