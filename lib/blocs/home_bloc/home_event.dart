part of 'home_bloc.dart';

@immutable
abstract class HomeEvent extends Equatable{
  @override
  List<Object> get props => [];
}

class HomeInitialEvent extends HomeEvent {
}

class HomeDeleteLocalFilesEvent extends HomeEvent {
  final List<DeletedFiles> deletedFiles;

  HomeDeleteLocalFilesEvent({@required this.deletedFiles});

  @override
  List<Object> get props => [deletedFiles];
}

class HomeRefreshLocalAndCloudSongbookEvent extends HomeEvent {}

class HomeCheckForAnyUpdatesEvent extends HomeEvent {}

class HomeCheckForDeletedFilesEvent extends HomeEvent {
}

class HomeDeleteFilesFromCloudEvent extends HomeEvent {
  final List<FileModel> deletedFiles;

  HomeDeleteFilesFromCloudEvent({@required this.deletedFiles});

  @override
  List<Object> get props => [deletedFiles];
}

class HomeOnSearchFileEvent extends HomeEvent {

  final String fileName;
  final List<FileModel> songbook;

  HomeOnSearchFileEvent({@required this.fileName, @required this.songbook});

  @override
  List<Object> get props => [fileName, songbook];
}

class HomeDownloadTheEntireSongbookEvent extends HomeEvent {}

class HomeUploadFilesToCloudEvent extends HomeEvent {
  final List<FileModel> newLocalFiles;

  HomeUploadFilesToCloudEvent({@required this.newLocalFiles});

  @override
  List<Object> get props => [newLocalFiles];
}

class HomeDownloadMissingFilesFilesEvent extends HomeEvent {
  final List<DatabaseLyricsFileInfo> newCloudFiles;

  HomeDownloadMissingFilesFilesEvent({@required this.newCloudFiles});

  @override
  List<Object> get props => [newCloudFiles];
}