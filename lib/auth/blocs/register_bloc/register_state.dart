part of 'register_bloc.dart';


@immutable
class RegisterState extends Equatable {

  @override
  List<Object> get props => [];
}

class RegisterInitialState extends RegisterState {}

class RegisterFailureState extends RegisterState {}

class RegisterLoadingState extends RegisterState {}

class RegisterSubmittingState extends RegisterState {}

class RegisterRegistrationSuccessState extends RegisterState {
  final User user;

  RegisterRegistrationSuccessState({@required this.user});

  @override
  List<Object> get props => [user];
}