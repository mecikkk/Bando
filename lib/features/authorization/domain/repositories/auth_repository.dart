import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signInWithEmailAndPassword(EmailAddress email, Password password);
  Future<Either<Failure, User>> signInWithGoogle();
  Future<Either<Failure, User>> registerWithEmailAndPassword(EmailAddress email, Password password, String username);
  Future<Either<Failure, User>> isLoggedIn();
  Future<void> loggOut();
}
