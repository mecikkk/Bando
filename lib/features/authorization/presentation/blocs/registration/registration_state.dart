part of 'registration_bloc.dart';

abstract class RegistrationState extends Equatable {
  const RegistrationState();
  
  @override
  List<Object> get props => [];
}

class RegistrationInitial extends RegistrationState {}

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