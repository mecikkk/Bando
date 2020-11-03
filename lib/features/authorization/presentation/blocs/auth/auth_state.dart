part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthorizedState extends AuthState {
  final User user;

  AuthorizedState({@required this.user});

  @override
  List<Object> get props => [user];
}

class UnauthorizedState extends AuthState {}

class SplashScreenState extends AuthState {}

class Error extends AuthState {
  final String message;

  Error({@required this.message});

  @override
  List<Object> get props => [message];
}

class LoadingState extends AuthState {}

class UnconfiguredGroupState extends AuthState {
  final User user;

  UnconfiguredGroupState({@required this.user});

  @override
  List<Object> get props => [user];
}
