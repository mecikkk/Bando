import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

abstract class Failure extends Equatable {
  final String message;

  Failure({@required this.message});

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
