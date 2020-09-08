part of 'login_bloc.dart';

@immutable
abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];

}

class LoginEmailChanged extends LoginEvent {
  final String email;

  const LoginEmailChanged({@required this.email});

  @override
  List<Object> get props => [email];

  @override
  String toString() => 'LoginEmailChanged(email :$email)';
}

class LoginPasswordChanged extends LoginEvent {
  final String password;

  const LoginPasswordChanged({@required this.password});

  @override
  List<Object> get props => [password];

  @override
  String toString() => 'LoginPasswordChanged(password: $password)';
}

class LoginWithGooglePressed extends LoginEvent {}

class LoginWithEmailPressed extends LoginEvent {
  final String email;
  final String password;

  const LoginWithEmailPressed({
    @required this.email,
    @required this.password,
  });

  @override
  List<Object> get props => [email, password];

  @override
  String toString() {
    return 'LoginWithEmailPressed(email: $email, password: $password)';
  }
}