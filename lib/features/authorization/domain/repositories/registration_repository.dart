import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

abstract class RegistrationRepository {
  Future<Either<Failure, User>> registerWithEmailAndPassword(EmailAddress email, Password password, String username);
}