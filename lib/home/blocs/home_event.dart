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

class HomeConfigureSongbookDirectoryEvent extends HomeEvent {
  final FileModel directoryToMove;

  HomeConfigureSongbookDirectoryEvent({@required this.directoryToMove});

  @override
  List<Object> get props => [directoryToMove];
}

class HomeUploadSongbookToCloudEvent extends HomeEvent {
}

class HomeGroupConfiguredEvent extends HomeEvent {
  final Group group;

  HomeGroupConfiguredEvent({@required this.group});

  @override
  List<Object> get props => [group];
}
