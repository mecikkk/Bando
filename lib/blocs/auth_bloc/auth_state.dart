part of 'auth_bloc.dart';

@immutable
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];

}

class AuthInitial extends AuthState {}

class Authenticated extends AuthState {
  final String uid;

  const Authenticated(this.uid);

  @override
  List<Object> get props => [uid];

  @override
  String toString() {
    return 'AuthSuccess(uid : $uid)';
  }
}

class Unauthenticated extends AuthState {}
