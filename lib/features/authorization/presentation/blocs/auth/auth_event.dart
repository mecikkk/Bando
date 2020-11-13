part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}
class AuthStart extends AuthEvent {}
class LogoutEvent extends AuthEvent {}

class SignInWithEmailAndPasswordEvent extends AuthEvent {
  final EmailAddress email;
  final Password password;

  SignInWithEmailAndPasswordEvent({@required this.email, @required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignInWithGoogleEvent extends AuthEvent {}
