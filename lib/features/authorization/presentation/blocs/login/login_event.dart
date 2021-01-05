part of 'login_bloc.dart';

@immutable
abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class SignInWithEmailAndPasswordEvent extends LoginEvent {
  final String email;
  final String password;

  SignInWithEmailAndPasswordEvent({@required this.email, @required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignInWithGoogleEvent extends LoginEvent {}

class EmailTextFieldChanged extends LoginEvent {
  final String enteredText;

  EmailTextFieldChanged({this.enteredText});

  @override
  List<Object> get props => [enteredText];
}

class PasswordTextFieldChanged extends LoginEvent {
  final String enteredText;

  PasswordTextFieldChanged({this.enteredText});

  @override
  List<Object> get props => [enteredText];
}

class ResetPasswordEvent extends LoginEvent {
  final String email;

  ResetPasswordEvent({this.email});

  @override
  List<Object> get props => [email];
}