part of 'register_bloc.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

class RegisterEmailChanged extends RegisterEvent {
  final String email;

  const RegisterEmailChanged({@required this.email});

  @override
  List<Object> get props => [email];
}

class RegisterPasswordChanged extends RegisterEvent {
  final String password;

  const RegisterPasswordChanged({@required this.password});

  @override
  List<Object> get props => [password];
}

class RegisterUsernameChanged extends RegisterEvent {
  final String username;

  const RegisterUsernameChanged({@required this.username});

  @override
  List<Object> get props => [username];
}

class RegisterGroupNameChanged extends RegisterEvent {
  final String groupName;

  const RegisterGroupNameChanged({@required this.groupName});

  @override
  List<Object> get props => [groupName];
}

class RegisterSubmittedEvent extends RegisterEvent {
  final String email;
  final String password;
  final String username;

  const RegisterSubmittedEvent({
    @required this.email,
    @required this.password,
    @required this.username
  });

  @override
  List<Object> get props => [email, password, username];
}

class RegisterNewGroupCreating extends RegisterEvent {}

class RegisterJoiningToGroup extends RegisterEvent {}

class RegisterSubmittedNewGroup extends RegisterEvent {
  final String groupName;

  const RegisterSubmittedNewGroup({
    @required this.groupName,
  });

  @override
  List<Object> get props => [groupName];
}


class RegisterSubmittedJoinToGroup extends RegisterEvent {
  final String groupId;

  const RegisterSubmittedJoinToGroup({
    @required this.groupId,
  });

  @override
  List<Object> get props => [groupId];
}