part of 'login_bloc.dart';

@immutable
abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoadingState extends LoginState {}

class NotConfiguredGroupState extends LoginState {
  final User user;

  NotConfiguredGroupState({@required this.user});

  @override
  List<Object> get props => [user];
}

class WrongEmailOrPasswordState extends LoginState {
  final String message = 'wrong_email_password';

  WrongEmailOrPasswordState();
}

class GoogleAuthCanceledState extends LoginState {
  final String message = "google_auth_canceled";

  GoogleAuthCanceledState();
}

class LoggingInSuccessState extends LoginState {
  final User user;

  LoggingInSuccessState({@required this.user});

  @override
  List<Object> get props => [user];
}

class Error extends LoginState {
  final String message;

  Error({@required this.message});

  @override
  List<Object> get props => [message];
}

class EmailFieldChangedState extends LoginState {
  final String message;

  EmailFieldChangedState(this.message);

  @override
  List<Object> get props => [message];
}

class PasswordFieldChangedState extends LoginState {
  final String message;

  PasswordFieldChangedState(this.message);

  @override
  List<Object> get props => [message];
}

class ResetPasswordFailureState extends LoginState {
  final String message;

  ResetPasswordFailureState(this.message);

  @override
  List<Object> get props => [message];
}

class ResetPasswordSuccessState extends LoginState {}