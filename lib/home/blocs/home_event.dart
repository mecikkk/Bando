part of 'home_bloc.dart';

@immutable
abstract class HomeEvent extends Equatable{
  @override
  List<Object> get props => [];
}

class HomeInitialEvent extends HomeEvent {
}

class HomeConfigureSongbookDirectoryEvent extends HomeEvent {
  final FileModel directoryToMove;

  HomeConfigureSongbookDirectoryEvent({@required this.directoryToMove});

  @override
  List<Object> get props => [directoryToMove];
}

class HomeUploadSongbookToCloudEvent extends HomeEvent {
}

class HomeOnSearchFileEvent extends HomeEvent {

  final String fileName;
  final List<FileModel> songbook;

  HomeOnSearchFileEvent({@required this.fileName, @required this.songbook});

  @override
  List<Object> get props => [fileName, songbook];
}

class HomeGroupConfiguredEvent extends HomeEvent {
  final Group group;

  HomeGroupConfiguredEvent({@required this.group});

  @override
  List<Object> get props => [group];
}
