import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/login_register/data/repositories/login_register_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

class RegisterWithEmailAndPassword {
  final LoginRegisterRepositoryImpl repository;

  RegisterWithEmailAndPassword({@required this.repository});

// TODO : Dodać display name !
// TODO : Confirm email dac w blocku i validacje tez

  Future<Either<Failure, User>> call(EmailAddress email, Password password, String username) async {
    return await repository.registerWithEmailAndPassword(email, password, username);
  }
}
