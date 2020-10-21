part of 'profile_bloc.dart';

@immutable
abstract class ProfileEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ProfileInitialEvent extends ProfileEvent {}

class ProfileLoadAllDataEvent extends ProfileEvent {}

class ProfileLogoutEvent extends ProfileEvent {}

class ProfileChangeLeaderEvent extends ProfileEvent {
  final String newLeaderId;

  ProfileChangeLeaderEvent({@required this.newLeaderId});

  @override
  List<Object> get props => [newLeaderId];
}

class ProfileChangeUsernameEvent extends ProfileEvent {
  final String newUsername;

  ProfileChangeUsernameEvent({@required this.newUsername});

  @override
  List<Object> get props => [newUsername];
}

class ProfileChangePasswordEvent extends ProfileEvent {
  final String password;

  ProfileChangePasswordEvent({@required this.password});

  @override
  List<Object> get props => [password];
}