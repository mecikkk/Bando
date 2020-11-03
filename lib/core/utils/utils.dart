import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

Either<Failure, bool> isEmailValid(EmailAddress email) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(email.value)) return Left(EmailAddressFailure(message: 'Invalid email'));

  return Right(true);
}

Either<Failure, bool> isPasswordValid(Password password) {
  String pattern = r'^(?=.*[0-9])(?=.*[a-z]).{6,}$';

  RegExp regExp = RegExp(pattern);
  if (password.value.isEmpty) return Left(PasswordFailure(message: 'Password can\'t be empty'));
  if (!regExp.hasMatch(password.value)) return Left(PasswordFailure(message: 'At least 6 characters, and one digit'));
  return Right(true);
}
