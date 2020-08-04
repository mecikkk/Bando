import 'dart:async';
import 'dart:io';

import 'package:bando/auth/models/group_model.dart';
import 'package:bando/auth/models/update_file_info_model.dart';
import 'package:bando/auth/models/user_model.dart';
import 'package:bando/file_manager/models/file_model.dart';
import 'package:bando/file_manager/utils/files_utils.dart';
import 'package:bando/repositories/firebase_storage_repository.dart';
import 'package:bando/repositories/realtime_database_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';

import 'file:///D:/Android/Bando/FlutterProject/bando/lib/repositories/firestore_group_repository.dart';
import 'file:///D:/Android/Bando/FlutterProject/bando/lib/repositories/firestore_user_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FirestoreUserRepository _userRepository;
  final FirestoreGroupRepository _groupRepository;
  final FirebaseStorageRepository _storageRepository;
  final RealtimeDatabaseRepository _databaseRepository;

  HomeBloc({
    @required FirestoreUserRepository userRepository,
    @required FirestoreGroupRepository groupRepository,
    @required FirebaseStorageRepository storageRepository,
    @required RealtimeDatabaseRepository databaseRepository,
  })  : assert(userRepository != null),
        _userRepository = userRepository,
        assert(groupRepository != null),
        _groupRepository = groupRepository,
        assert(storageRepository != null),
        _storageRepository = storageRepository,
        assert(databaseRepository != null),
        _databaseRepository = databaseRepository,
        super(HomeInitialState());

  @override
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {
    if (event is HomeInitialEvent) {
      yield* _mapHomeInitialEventToState();
    } else if (event is HomeGroupConfiguredEvent) {
      yield* _mapHomeGroupConfiguredEventToState(event.group);
    } else if (event is HomeConfigureSongbookDirectoryEvent) {
      yield* _mapHomeConfigureSongbookDirectoryEventToState(event.directoryToMove);
    } else if (event is HomeUploadSongbookToCloudEvent) {
      yield* _mapHomeUploadSongbookToCloudEventToState();
    } else if (event is HomeOnSearchFileEvent) {
      yield* _mapHomeOnSearchFileEventToState(event.fileName, event.songbook);
    }
  }

  Stream<HomeState> _mapHomeInitialEventToState() async* {
    yield HomeLoadingState();

    try {
      User user = await _userRepository.currentUser();

      if (user.groupId != "") {
        Group group = await _groupRepository.getGroup(user.groupId);
        //await _storageRepository.getAllFiles(group.groupId);
        yield HomeReadyState(group: group, user: user);
      } else {
        yield HomeNoGroupState(user: user);
      }
    } catch (_) {
      yield HomeFailureState();
    }
  }

  Stream<HomeState> _mapHomeGroupConfiguredEventToState(Group group) async* {
    yield HomeGroupConfiguredState(group: group);
  }

  Stream<HomeState> _mapHomeConfigureSongbookDirectoryEventToState(FileModel directoryToMove) async* {
    yield HomeLoadingState();

    try {
      var result = await FilesUtils.moveSelectedDirToBandoDir(directoryToMove.fileSystemEntity.path);
      if (result == true)
        yield HomeSelectedDirectoryMovedState();
      else
        yield HomeFailureState();
    } catch (e) {
      print(e);
    }
  }

  Stream<HomeState> _mapHomeOnSearchFileEventToState(String fileName, List<FileModel> songbook) async* {
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

    allFiles.forEach((element) {
      print(element.getFileName());
    });

    result = allFiles.where((file) => file.getFileName().toLowerCase().contains(fileName.toLowerCase())).toList();
    print("YIELD !");
    yield HomeSearchResultState(searchResult: result);
  }

  Stream<HomeState> _mapHomeUploadSongbookToCloudEventToState() async* {
    yield HomeUploadingSongbookState();

    try {
      User user = await _userRepository.currentUser();

      _storageRepository.setGroupId(user.groupId);

      await _createReferenceList();

      List<UpdateFileInfo> uploadedFilesInfo = await _storageRepository.uploadAllFiles();
      List<String> downloadUrls = uploadedFilesInfo.map((e) => e.downloadUrl).toList();

      await _groupRepository.setGroupShouldUpdateSongbook(user.uid, user.groupId);
      await _groupRepository.setListOfUrls(downloadUrls, user.groupId);

      await _databaseRepository.addUpdateInfo(
        user.groupId,
        user.username,
        uploadedFilesInfo.map((e) => {'name': e.fileName, 'downloadUrl': e.downloadUrl}).toList(),
      );

      yield HomeUploadSongbookSuccessState();
    } catch (e) {
      print(e);
      yield HomeFailureState();
    }
  }

  Future _createReferenceList({Directory dir, String firebasePath = ""}) async {
    Directory songbookDir;
    String firebaseStoragePath = firebasePath;

    if (dir == null)
      songbookDir = await FilesUtils.getSongbookDirectory();
    else
      songbookDir = dir;

    List<FileSystemEntity> allFiles = FilesUtils.sortList(songbookDir.listSync());

    for (var element in allFiles.reversed) {
      if (FileSystemEntity.isDirectorySync(element.path)) {
        if (firebasePath == "")
          firebaseStoragePath = "${basename(element.path)}";
        else
          firebaseStoragePath = "$firebaseStoragePath/${basename(element.path)}";

        _createReferenceList(dir: Directory(element.path), firebasePath: firebaseStoragePath);
      } else {
//        await _storageRepository.uploadFile(File(element.path), subDir: firebaseStoragePath);
        _storageRepository.addStorageReference(File(element.path), subDir: firebaseStoragePath);
      }
    }
  }
}
