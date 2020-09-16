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

class HomeShowLoadingState extends HomeState {
  final String message;
  final LoadingType loadingType;

  HomeShowLoadingState({this.message = "", @required this.loadingType});

  @override
  List<Object> get props => [message, loadingType];
}

class HomeNeedToDeleteFilesLocallyState extends HomeState {
  final List<DeletedFiles> updates;

  HomeNeedToDeleteFilesLocallyState({@required this.updates});

  @override
  List<Object> get props => [updates];
}

class HomeReloadSongbookAndHideUpdatesInfo extends HomeState {
  final List<FileModel> songbook;

  HomeReloadSongbookAndHideUpdatesInfo({@required this.songbook});

  @override
  List<Object> get props => [songbook];
}

class HomeStartCheckingUpdatesState extends HomeState {}

class HomeUploadSongbookSuccessState extends HomeState {}

class HomeNeedToDownloadTheEntireSongbookState extends HomeState {
  final User user;
  final Group group;

  HomeNeedToDownloadTheEntireSongbookState({@required this.user, @required this.group});

  @override
  List<Object> get props => [user, group];
}

class HomeNeedToUploadLocalSongbookToCloudState extends HomeState {
  final User user;
  final Group group;

  HomeNeedToUploadLocalSongbookToCloudState({@required this.user, @required this.group});

  @override
  List<Object> get props => [user, group];
}

class HomeReadyState extends HomeState {
  final List<FileModel> songbook;
  final User user;
  final Group group;

  HomeReadyState({@required this.songbook, @required this.user, @required this.group});

  @override
  List<Object> get props => [songbook, user, group];
}

class HomeReloadSongbook extends HomeState {
  final List<FileModel> songbook;

  HomeReloadSongbook({this.songbook});

  @override
  List<Object> get props => [songbook];
}

class HomeFailureState extends HomeState {
  final String message;

  HomeFailureState({this.message = "Wystąpił problem..."});

  @override
  List<Object> get props => [message];
}

class HomeSearchResultState extends HomeState {
  final List<FileModel> searchResult;

  HomeSearchResultState({@required this.searchResult});

  @override
  List<Object> get props => [searchResult];
}

class HomeCheckingSongbookCompleteState extends HomeState {
  final List<FileModel> newLocalFiles;
  final List<DatabaseLyricsFileInfo> newCloudFiles;

  HomeCheckingSongbookCompleteState({@required this.newLocalFiles, @required this.newCloudFiles});

  @override
  List<Object> get props => [newCloudFiles, newLocalFiles];
}
