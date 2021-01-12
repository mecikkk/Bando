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

class _Validation extends RegistrationEvent {
  final String enteredText;


  _Validation({this.enteredText});

  @override
  List<Object> get props => [enteredText];
}

class ValidateRegistrationUsernameEvent extends _Validation {
  ValidateRegistrationUsernameEvent({String enteredText}) : super(enteredText : enteredText);
}

class ValidateRegistrationEmailEvent extends _Validation {
  ValidateRegistrationEmailEvent({String enteredText}) : super(enteredText : enteredText);
}

class ValidateRegistrationPasswordEvent extends _Validation {
  ValidateRegistrationPasswordEvent({String enteredText}) : super(enteredText : enteredText);
}
