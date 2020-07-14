import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class FileManagerBloc extends Bloc<FileManagerEvent, FileManagerState> {

  FileManagerBloc(FileManagerState initialState) : super(initialState);

  @override
  FileManagerState get initialState => InitialFileManagerState();

  @override
  Stream<FileManagerState> mapEventToState(FileManagerEvent event,) async* {



  }
}
