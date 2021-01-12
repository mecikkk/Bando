part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}
class AuthStart extends AuthEvent {}
class LogoutEvent extends AuthEvent {}
class SignedIn extends AuthEvent {
  final User user;

  SignedIn({this.user});

  @override
  List<Object> get props => [user];
}
