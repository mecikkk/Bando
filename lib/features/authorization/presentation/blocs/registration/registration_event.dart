part of 'registration_bloc.dart';

abstract class RegistrationEvent extends Equatable {
  const RegistrationEvent();

  @override
  List<Object> get props => [];
}

class RegisterWithEmailAndPasswordEvent extends RegistrationEvent {
  final String email;
  final String password;
  final String username;

  RegisterWithEmailAndPasswordEvent({@required this.email, @required this.password, @required this.username});

  @override
  List<Object> get props => [email, password, username];
}
