import 'package:bando/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

Either<Failure, bool> isEmailValid(String email) {
  if(email.isEmpty) return Left(EmailAddressFailure(message: 'empty_email'));
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(email)) return Left(EmailAddressFailure(message: "invalid_email"));

  return Right(true);
}

Either<Failure, bool> isPasswordValid(String password) {
  String pattern = r'^(?=.*[0-9])(?=.*[a-z]).{6,}$';

  RegExp regExp = RegExp(pattern);
  if (password.isEmpty) return Left(PasswordFailure(message: 'password_empty'));
  if (!regExp.hasMatch(password)) return Left(PasswordFailure(message: 'invalid_password'));
  return Right(true);
}