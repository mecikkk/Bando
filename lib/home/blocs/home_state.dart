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

class HomeUploadingSongbookState extends HomeState {
  final String message;

  HomeUploadingSongbookState({@required this.message});

  @override
  List<Object> get props => [message];
}

class HomeCheckSongbookState extends HomeState {
  final Group group;
  final User user;

  HomeCheckSongbookState({@required this.group, @required this.user});

  @override
  List<Object> get props => [group, user];
}

class HomeNeedToUpdateSongbookState extends HomeState {
  final List<UpdateInfo> updates;

  HomeNeedToUpdateSongbookState({@required this.updates});

  @override
  List<Object> get props => [updates];
}

class HomeUploadSongbookSuccessState extends HomeState {}

class HomeSongbookUpdateSuccessState extends HomeState {}

class HomeNeedToDownloadFilesState extends HomeState {}

class HomeLocalSongbookLoadedState extends HomeState {
  final List<FileModel> songbook;

  HomeLocalSongbookLoadedState({@required this.songbook});

  @override
  List<Object> get props => [songbook];
}

class HomeEmptyLibraryState extends HomeState {}

class HomeReadyState extends HomeState {}

class HomeDownloadingProgressState extends HomeState {
  final int currentFile;
  final int count;


  HomeDownloadingProgressState({@required this.currentFile,@required this.count});

  @override
  List<Object> get props => [currentFile, count];
}

class HomeGroupConfiguredState extends HomeState {
  final Group group;

  HomeGroupConfiguredState({@required this.group});

  @override
  List<Object> get props => [group];
}

class HomeSelectedDirectoryMovedState extends HomeState {}

class HomeFailureState extends HomeState {}

class HomeSearchResultState extends HomeState {

  final List<FileModel> searchResult;

  HomeSearchResultState({@required this.searchResult});

  @override
  List<Object> get props => [searchResult];
}