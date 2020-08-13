import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:bando/auth/entities/update_file_info_entity.dart';
import 'package:bando/auth/models/group_model.dart';
import 'package:bando/auth/models/update_file_info_model.dart';
import 'package:bando/auth/models/update_info_model.dart';
import 'package:bando/auth/models/user_model.dart';
import 'package:bando/file_manager/models/file_model.dart';
import 'package:bando/file_manager/utils/files_utils.dart';
import 'package:bando/repositories/firebase_storage_repository.dart';
import 'package:bando/repositories/realtime_database_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
    } else if (event is HomeLoadLocalSongbookEvent) {
      yield* _mapHomeLoadLocalSongbookEventToState();
    } else if (event is HomeDownloadAllSongbookFilesEvent) {
      yield* _mapHomeDownloadAllSongbookFilesEventToState();
    } else if (event is HomeCheckSongbookEvent) {
      yield* _mapHomeCheckSongbookEventToState(event.groupId);
    } else if (event is HomeCheckSongbookUpdatesEvent) {
      yield* _mapHomeCheckSongbookUpdatesEventToState(event.groupId);
    } else if (event is HomeUpdateSongbookEvent) {
      yield* _mapHomeUpdateSongbookEventToState(event.updates);
    }
  }

  Stream<HomeState> _mapHomeInitialEventToState() async* {
    yield HomeLoadingState();

    try {
      final SharedPreferences _pref = await SharedPreferences.getInstance();
      User user;

      // TODO : CLEAR SHARED PREFERENCES WHEN LOGOUT

      // Load user and group basic information from shared pref. if is set up
      if (_pref.getString('username') == null || _pref.getString('uid') == null) {
        debugPrint("Load USER info from firestore and store to shared pref");
        user = await _userRepository.currentUser();
        _pref.setString('username', user.username);
        _pref.setString('uid', user.uid);
        if (user.groupId != "") _pref.setString('groupId', user.groupId);
      } else {
        debugPrint("Load USER info from shared pref");

        user = User(
          _pref.getString('uid'),
          username: _pref.getString('username'),
          groupId: _pref.getString('groupId') ?? '',
        );
      }

      if (user.groupId != "") {
        Group group;
        if (_pref.getString('groupId') == null || _pref.getString('groupName') == null) {
          debugPrint("Load GROUP info from firestore and store to shared pref");

          group = await _groupRepository.getGroup(user.groupId);
          _pref.setString('groupName', group.name);
          _pref.setString('groupId', group.groupId);
        } else {
          debugPrint("Load GROUP info from shared pref");

          group = Group(
            _pref.getString('groupId'),
            name: _pref.getString('groupName'),
          );
        }

        yield HomeCheckSongbookState(user: user, group: group);
      } else {
        yield HomeNoGroupState(user: user);
      }
    } catch (_) {
      yield HomeFailureState();
    }
  }

  Stream<HomeState> _mapHomeCheckSongbookEventToState(String groupId) async* {
    Directory localSongbookDir = await FilesUtils.getSongbookDirectory();
    bool isLocalSongbookEmpty = localSongbookDir.listSync(recursive: true).isEmpty;

    if (isLocalSongbookEmpty) {
      var list = await _groupRepository.getAllLyricsFilesInfo(groupId);
      if (list.isEmpty)
        yield HomeEmptyLibraryState();
      else
        yield HomeNeedToDownloadFilesState();
    } else {
      yield HomeReadyState();
    }
  }

  Stream<HomeState> _mapHomeDownloadAllSongbookFilesEventToState() async* {

    yield HomeUploadingSongbookState(message: "Pobieram teksty z biblioteki...");
    String groupId = await _userRepository.getUserGroupId();


    var list = await _groupRepository.getAllLyricsFilesInfo(groupId);

    int counter = 1;

    for (var fileInfo in list) {
      final Directory systemDir = await FilesUtils.getSongbookDirectory();
      final String fullPath = "${systemDir.path}/${fileInfo.localPath}";

      await downloadFile(uri: fileInfo.downloadUrl, fullPath: fullPath, count: list.length, current: counter);
      yield HomeDownloadingProgressState(count: list.length, currentFile: counter);

      counter++;
    }

    await _userRepository.setLastUpdateTime(Timestamp.fromDate(DateTime.now()).millisecondsSinceEpoch);

    yield HomeReadyState();
  }

  Future<void> downloadFile({String uri, String fullPath, int count, int current}) async {
    Dio dio = Dio();

    String progress = "0";

    await dio.download(
      uri,
      fullPath,
      onReceiveProgress: (rcv, total) {
        progress = ((rcv / total) * 100).toStringAsFixed(0);
      },
      deleteOnError: true,
    ).then((_) {
      if (progress == "100") {
        debugPrint("DONE !");
        return;
      }
    });
  }

  Stream<HomeState> _mapHomeCheckSongbookUpdatesEventToState(String groupId) async* {

    final int lastUpdate = await _userRepository.getLastUpdateTime();
    final List<UpdateInfo> updates = await _databaseRepository.getUpdatedFiles(groupId, lastUpdate);

    if(updates.isNotEmpty) {
      // TODO : need to update
      yield HomeNeedToUpdateSongbookState(updates: updates);
    }

  }

  Stream<HomeState> _mapHomeUpdateSongbookEventToState(List<UpdateInfo> updates) async* {
    yield HomeUploadingSongbookState(message: "Pobieranie...");

    List<DatabaseLyricsFileInfo> list = List();

    updates.forEach((element) {
      element.files.forEach((map) {
        list.add(DatabaseLyricsFileInfo.fromEntity(DatabaseLyricsFileInfoEntity.fromMap(map)));
      });
    });

    int counter = 1;

    for (var fileInfo in list) {
      final Directory systemDir = await FilesUtils.getSongbookDirectory();
      final String fullPath = "${systemDir.path}/${fileInfo.localPath}";

      await downloadFile(uri: fileInfo.downloadUrl, fullPath: fullPath, count: list.length, current: counter);
      yield HomeDownloadingProgressState(count: list.length, currentFile: counter);

      counter++;
    }

    await _userRepository.setLastUpdateTime(Timestamp.fromDate(DateTime.now()).millisecondsSinceEpoch);

    yield HomeSongbookUpdateSuccessState();

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

    yield HomeSearchResultState(searchResult: result);
  }

  Stream<HomeState> _mapHomeUploadSongbookToCloudEventToState() async* {
    yield HomeUploadingSongbookState(message: "Udostępniam pliki grupie...");

    try {
      User user = await _userRepository.currentUser();

      _storageRepository.setGroupId(user.groupId);

      await _createReferenceListOfAllFilesInSongbookDir();

      List<DatabaseLyricsFileInfo> uploadedFilesInfo = await _storageRepository.uploadAllFiles();

      await _groupRepository.setGroupShouldUpdateSongbook(user.uid, user.groupId);
      await _groupRepository.updateLyricsFilesInfo(uploadedFilesInfo, user.groupId);

      await _databaseRepository.addUpdateInfo(
        user.groupId,
        user.username,
        uploadedFilesInfo
            .map((e) => {'name': e.fileName, 'downloadUrl': e.downloadUrl, 'localPath': e.localPath})
            .toList(),
      );

      await _userRepository.setLastUpdateTime(Timestamp.fromDate(DateTime.now()).millisecondsSinceEpoch);

      yield HomeUploadSongbookSuccessState();
    } catch (e) {
      print(e);
      yield HomeFailureState();
    }
  }

  Future _createReferenceListOfAllFilesInSongbookDir({Directory dir, String firebasePath = ""}) async {
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

        _createReferenceListOfAllFilesInSongbookDir(dir: Directory(element.path), firebasePath: firebaseStoragePath);
      } else {
//        await _storageRepository.uploadFile(File(element.path), subDir: firebaseStoragePath);
        _storageRepository.addStorageReference(File(element.path), subDir: firebaseStoragePath);
      }
    }
  }

  Stream<HomeState> _mapHomeLoadLocalSongbookEventToState() async* {
    yield HomeLoadingState();
    List<FileModel> songbook = List();

    try {
      debugPrint("Start Loading local songbook");
      Directory songbookDirectory = await FilesUtils.getSongbookDirectory();

      if (songbookDirectory.listSync().isNotEmpty) songbook = await FilesUtils.getFilesInPath(songbookDirectory.path);

      yield HomeLocalSongbookLoadedState(songbook: songbook);
    } catch (e) {
      debugPrint("Getting local songbook error : $e");
      yield HomeFailureState();
    }
  }
}
