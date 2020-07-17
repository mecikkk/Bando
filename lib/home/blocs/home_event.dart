part of 'home_bloc.dart';

@immutable
abstract class HomeEvent extends Equatable{
  @override
  List<Object> get props => [];
}

class HomeInitialEvent extends HomeEvent {
  final String uid;

  HomeInitialEvent({@required this.uid});

  @override
  List<Object> get props => [uid];
}
