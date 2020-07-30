import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:bando/auth/models/group_model.dart';
import 'package:bando/auth/models/user_model.dart';
import 'package:bando/auth/repository/firestore_group_repository.dart';
import 'package:bando/auth/repository/firestore_user_repository.dart';
import 'package:bando/file_manager/models/file_model.dart';
import 'package:bando/file_manager/utils/files_utils.dart';
import 'package:bando/repositories/firebase_storage_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FirestoreUserRepository _userRepository;
  final FirestoreGroupRepository _groupRepository;
  final FirebaseStorageRepository _storageRepository;

  HomeBloc({
    @required FirestoreUserRepository userRepository,
    @required FirestoreGroupRepository groupRepository,
    @required FirebaseStorageRepository storageRepository,
  })  : assert(userRepository != null),
        _userRepository = userRepository,
        assert(groupRepository != null),
        _groupRepository = groupRepository,
        assert(storageRepository != null),
        _storageRepository = storageRepository,
        super(HomeInitialState());

  @override
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {
    if (event is HomeInitialEvent) {
      yield* _mapHomeInitialEventToState(event.uid);
    } else if (event is HomeGroupConfiguredEvent) {
      yield* _mapHomeGroupConfiguredEventToState(event.group);
    } else if (event is HomeConfigureSongbookDirectoryEvent) {
      yield* _mapHomeConfigureSongbookDirectoryEventToState(event.directoryToMove);
    } else if (event is HomeUploadSongbookToCloudEvent) {
      yield* _mapHomeUploadSongbookToCloudEventToState();
    } else if (event is HomeOnSearchFileEvent){
      yield* _mapHomeOnSearchFileEventToState(event.fileName, event.songbook);
    }
  }

  Stream<HomeState> _mapHomeInitialEventToState(String uid) async* {
    yield HomeLoadingState();

    try {
      User user = await _userRepository.getUser(uid);

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

    for(var element in songbook) {
      if (element.isDirectory) {
        List<FileModel> subdir = await FilesUtils.getFilesInPath(element.fileSystemEntity.path);
        subdir.forEach((file) { allFiles.add(file);});
      } else {
        allFiles.add(element);
      }
    }

    allFiles.forEach((element) { print(element.getFileName());});

    result = allFiles.where((file) => file.getFileName().toLowerCase().contains(fileName.toLowerCase())).toList();
    print("YIELD !");
    yield HomeSearchResultState(searchResult: result);
  }

  Stream<HomeState> _mapHomeUploadSongbookToCloudEventToState() async* {
    yield HomeUploadingSongbookState();

    try {
      String groupId = await _userRepository.getUserGroupId();
      _storageRepository.setGroupId(groupId);

      await _uploadFilesToStorage();

      String uid = await _userRepository.currentUserId();
      await _groupRepository.setGroupShouldUpdateSongbook(uid, groupId);

      yield HomeUploadSongbookSuccessState();
    } catch (e) {
      print(e);
      yield HomeFailureState();
    }
  }

  Future _uploadFilesToStorage({Directory dir, String firebasePath = ""}) async {
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

        _uploadFilesToStorage(dir: Directory(element.path), firebasePath: firebaseStoragePath);
      } else {
        await _storageRepository.uploadFile(File(element.path), subDir: firebaseStoragePath);
      }
    }

//    allFiles.reversed.forEach((element) async {
//
//    });
  }
}
