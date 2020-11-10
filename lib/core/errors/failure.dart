import 'package:bando/core/entities/user.dart';
import 'package:bando/core/utils/constants.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

abstract class Failure extends Equatable {
  final String message;

  Failure({this.message = ''});

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {}

class LoginFailure extends Failure {
  LoginFailure({@required String message}) : super(message: message);
}

class EmailAddressFailure extends Failure {
  EmailAddressFailure({@required String message}) : super(message: message);
}

class PasswordFailure extends Failure {
  PasswordFailure({@required String message}) : super(message: message);
}

class Unauthorized extends Failure {}

class GoogleAuthCanceled extends Failure {
  GoogleAuthCanceled() : super(message: FIREBASE_CANCELED_BY_USER);
}

class EmailAlreadyInUse extends Failure {
  EmailAlreadyInUse() : super(message: FIREBASE_EMAIL_ALREADY_IN_USE);
}

class WrongEmailOrPassword extends Failure {
  WrongEmailOrPassword() : super(message: FIREBASE_WRONG_EMAIL_OR_PASSWORD);
}

class UnconfiguredGroup extends Failure {
  final User user;

  UnconfiguredGroup({@required this.user});

  @override
  List<Object> get props => [user];
}
