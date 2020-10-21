import 'dart:async';

import 'package:bando/models/file_model.dart';
import 'package:bando/utils/files_utils.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial());

  @override
  Stream<SearchState> mapEventToState(
    SearchEvent event,
  ) async* {
    if(event is OnSearchEvent) {
      yield* _mapOnSearchEventToState(event.fileName, event.songbook);
    }
  }


  Stream<SearchState> _mapOnSearchEventToState(String fileName, List<FileModel> songbook) async* {

    List<FileModel> allFiles = List();
    List<FileModel> result = List();

    for (var element in songbook) {
      if (element.isDirectory) {
        List<FileModel> subdir = await FilesUtils.getFilesInPath(element.fileSystemEntity.path);
        subdir.forEach((file) {
          allFiles.add(file);
        });
      } else {
        allFiles.add(element);
      }
    }

    debugPrint("searchQery : $fileName");


    result = allFiles.where((file) => file.fileName().toLowerCase().contains(fileName.toLowerCase())).toList();

    result.forEach((element) {
      print(element.fileName());
    });

    yield SearchResultState(searchResult: result);

  }
}
