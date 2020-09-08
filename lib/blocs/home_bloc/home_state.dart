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

class HomeBasicInfoLoadedState extends HomeState {
  final Group group;
  final User user;

  HomeBasicInfoLoadedState({@required this.group, @required this.user});

  @override
  List<Object> get props => [group, user];
}

class HomeShowLoadingState extends HomeState {
  final String message;
  final LoadingType loadingType;

  HomeShowLoadingState({this.message = "", @required this.loadingType});

  @override
  List<Object> get props => [message, loadingType];
}

class HomeNeedToUpdateSongbookState extends HomeState {
  final List<DeletedFiles> updates;

  HomeNeedToUpdateSongbookState({@required this.updates});

  @override
  List<Object> get props => [updates];
}

class HomeUploadSongbookSuccessState extends HomeState {}

class HomeSongbookUpdateSuccessState extends HomeState {}

class HomeNeedToDownloadTheEntireSongbookState extends HomeState {}

class HomeLocalSongbookLoadedState extends HomeState {
  final List<FileModel> songbook;

  HomeLocalSongbookLoadedState({@required this.songbook});

  @override
  List<Object> get props => [songbook];
}

class HomeNeedToUploadLocalSongbookToCloudState extends HomeState {}

class HomeReadyState extends HomeState {}

class HomeGroupConfiguredState extends HomeState {
  final Group group;

  HomeGroupConfiguredState({@required this.group});

  @override
  List<Object> get props => [group];
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