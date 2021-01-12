part of 'registration_bloc.dart';

abstract class RegistrationState extends Equatable {
  const RegistrationState();
  
  @override
  List<Object> get props => [];
}

class RegistrationInitial extends RegistrationState {}

class RegistrationLoadingState extends RegistrationState {}

class RegistrationFailureState extends RegistrationState {
  final Failure failure;

  RegistrationFailureState({this.failure});

  @override
  List<Object> get props => [failure];
}

class RegistrationSuccess extends RegistrationState {
  final User user;

  RegistrationSuccess({this.user});

  @override
  List<Object> get props => [user];
}

class _RegistrationStateWithMessage extends RegistrationState {
  final String message;

  _RegistrationStateWithMessage({this.message});

  @override
  List<Object> get props => [message];
}

class UsernameVerifiedState extends _RegistrationStateWithMessage {
  UsernameVerifiedState({String message}) : super(message : message);
}

class EmailVerifiedState extends _RegistrationStateWithMessage {
  EmailVerifiedState({String message}) : super(message : message);
}

class PasswordVerifiedState extends _RegistrationStateWithMessage {
  PasswordVerifiedState({String message}) : super(message : message);
}