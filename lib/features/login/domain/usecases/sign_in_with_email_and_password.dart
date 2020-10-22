import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/login/domain/repositories/login_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

class SignInWithEmailAndPassword {
  final LoginRepository loginRepository;

  SignInWithEmailAndPassword(this.loginRepository);

  Future<Either<Failure, User>> call({@required EmailAddress email, @required Password password}) async {
    return loginRepository.signInUserWithEmailAndPassword(email, password);
  }
}
