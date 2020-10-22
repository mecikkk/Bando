import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

abstract class LoginRepository {
  Future<Either<Failure, User>> signInUserWithEmailAndPassword(EmailAddress email, Password password);
  Future<Either<Failure, User>> signInUserWithGoogle();
}
