part of 'search_bloc.dart';

@immutable
abstract class SearchState extends Equatable {
  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchResultState extends SearchState {
  final List<FileModel> searchResult;

  SearchResultState({@required this.searchResult});

  @override
  List<Object> get props => [searchResult];
}