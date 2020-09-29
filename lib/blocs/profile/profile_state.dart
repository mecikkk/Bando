part of 'profile_bloc.dart';

@immutable
abstract class ProfileState extends Equatable {
  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {
}
class ProfileSuccessState extends ProfileState {}

class ProfileLoadingState extends ProfileState {}

class ProfileFailureState extends ProfileState {}

class ProfileDataLoadedState extends ProfileState {
  final User user;
  final Group group;

  ProfileDataLoadedState({@required this.user, @required this.group});

  @override
  List<Object> get props => [user, group];
}