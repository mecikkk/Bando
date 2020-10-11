part of 'auth_bloc.dart';

@immutable
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];

}

class AuthInitial extends AuthState {}

class Authenticated extends AuthState {
  @override
  String toString() {
    return 'AuthSuccess()';
  }
}

class AuthLoggedInState extends AuthState {}

class Unauthenticated extends AuthState {}

class AuthLoggedOutState extends AuthState {}