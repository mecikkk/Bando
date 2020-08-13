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

class HomeCheckSongbookUpdatesEvent extends HomeEvent {
  final String groupId;

  HomeCheckSongbookUpdatesEvent({@required this.groupId});

  @override
  List<Object> get props => [groupId];
}

class HomeUpdateSongbookEvent extends HomeEvent {
  final List<UpdateInfo> updates;

  HomeUpdateSongbookEvent({@required this.updates});

  @override
  List<Object> get props => [updates];
}

class HomeOnSearchFileEvent extends HomeEvent {

  final String fileName;
  final List<FileModel> songbook;

  HomeOnSearchFileEvent({@required this.fileName, @required this.songbook});

  @override
  List<Object> get props => [fileName, songbook];
}

class HomeCheckSongbookEvent extends HomeEvent {
  final String groupId;

  HomeCheckSongbookEvent({@required this.groupId});

  @override
  List<Object> get props => [groupId];
}

class HomeLoadLocalSongbookEvent extends HomeEvent {}

class HomeDownloadAllSongbookFilesEvent extends HomeEvent {}

class HomeGroupConfiguredEvent extends HomeEvent {
  final Group group;

  HomeGroupConfiguredEvent({@required this.group});

  @override
  List<Object> get props => [group];
}
