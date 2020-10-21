part of 'search_bloc.dart';

@immutable
abstract class SearchEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class OnSearchEvent extends SearchEvent {

  final String fileName;
  final List<FileModel> songbook;

  OnSearchEvent({@required this.fileName, @required this.songbook});

  @override
  List<Object> get props => [fileName, songbook];
}