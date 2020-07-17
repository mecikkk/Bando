part of 'home_bloc.dart';

@immutable
abstract class HomeState extends Equatable {
  @override
  List<Object> get props => [];
}

class HomeInitialState extends HomeState {}

class HomeNoGroupState extends HomeState {
  final User user;

  HomeNoGroupState({@required this.user});

  @override
  List<Object> get props => [user];
}

class HomeLoadingState extends HomeState {}

class HomeReadyState extends HomeState {
  final Group group;
  final User user;

  HomeReadyState({@required this.group, @required this.user});

  @override
  List<Object> get props => [group, user];
}

class HomeFailureState extends HomeState {}