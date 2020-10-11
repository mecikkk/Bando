part of 'profile_bloc.dart';

@immutable
abstract class ProfileEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ProfileInitialEvent extends ProfileEvent {}

class ProfileLoadAllDataEvent extends ProfileEvent {}

class ProfileLogoutEvent extends ProfileEvent {}