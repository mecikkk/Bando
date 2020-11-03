import 'package:bando/core/entities/user.dart';
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

class UnconfiguredGroup extends Failure {
  final User user;

  UnconfiguredGroup({@required this.user});

  @override
  List<Object> get props => [user];
}
