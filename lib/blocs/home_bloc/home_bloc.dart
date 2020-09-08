import 'dart:async';
import 'dart:io';

import 'package:bando/entities/database_lyrics_file_info_entity.dart';
import 'file:///D:/Android/Bando/FlutterProject/bando/lib/models/file_model.dart';
import 'file:///D:/Android/Bando/FlutterProject/bando/lib/utils/files_utils.dart';
import 'package:bando/models/database_lyrics_file_info_model.dart';
import 'package:bando/models/deleted_files_model.dart';
import 'package:bando/models/group_model.dart';
import 'package:bando/models/user_model.dart';
import 'package:bando/repositories/firebase_storage_repository.dart';
import 'package:bando/repositories/firestore_group_repository.dart';
import 'package:bando/repositories/firestore_user_repository.dart';
import 'package:bando/repositories/realtime_database_repository.dart';
import 'package:bando/widgets/loading_widget.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      // }
      // else if (event is HomeConfigureSongbookDirectoryEvent) {
      //   yield* _mapHomeConfigureSongbookDirectoryEventToState(event.directoryToMove);
    } else if (event is HomeUploadSongbookToCloudEvent) {
      yield* _mapHomeUploadSongbookToCloudEventToState();
    } else if (event is HomeOnSearchFileEvent) {
      yield* _mapHomeOnSearchFileEventToState(event.fileName, event.songbook);
    } else if (event is HomeLoadLocalSongbookEvent) {
      yield* _mapHomeLoadLocalSongbookEventToState();
    } else if (event is HomeDownloadTheEntireSongbookEvent) {
      yield* _mapHomeDownloadTheEntireSongbookEventToState();
    } else if (event is HomeCheckSongbookEvent) {
      yield* _mapHomeCheckSongbookEventToState(event.groupId);
    } else if (event is HomeCheckForDeletedFilesEvent) {
      yield* _mapHomeCheckForDeletedFilesEventToState(event.groupId);
    } else if (event is HomeUpdateSongbookEvent) {
      yield* _mapHomeUpdateSongbookEventToState(event.updates);
    } else if (event is HomeCheckForNewLocalFilesEvent) {
      yield* _mapHomeCheckForNewLocalFilesEventToState();
    } else if (event is HomeUploadFilesToCloudEvent) {
      yield* _mapHomeUploadFilesToCloudEventToState(event.newLocalFiles);
    } else if (event is HomeDownloadMissingFilesFilesEvent) {
      yield* _mapHomeDownloadMissingFilesFilesEventToState(event.newCloudFiles);
    }
  }

  Stream<HomeState> _mapHomeInitialEventToState() async* {
    yield HomeShowLoadingState(loadingType: LoadingType.LOADING);

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

        yield HomeBasicInfoLoadedState(user: user, group: group);
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
        yield HomeNeedToUploadLocalSongbookToCloudState();
      else
        yield HomeNeedToDownloadTheEntireSongbookState();
    } else {
      yield HomeReadyState();
    }
  }

  Stream<HomeState> _mapHomeDownloadTheEntireSongbookEventToState() async* {
    yield HomeShowLoadingState(message: "Pobieram teksty z biblioteki...", loadingType: LoadingType.CLOUD_PROGRESS);

    try {
      String groupId = await _userRepository.getUserGroupId();

      var list = await _groupRepository.getAllLyricsFilesInfo(groupId);

      int count = list.length;
      int fileNum = 1;

      for (var fileInfo in list) {
        final Directory systemDir = await FilesUtils.getSongbookDirectory();
        final String fullPath = "${systemDir.path}/${fileInfo.localPath}";

        await downloadFile(uri: fileInfo.downloadUrl, fullPath: fullPath, count: count, current: fileNum);

        yield HomeShowLoadingState(message: "Pobieranie $fileNum / $count", loadingType: LoadingType.CLOUD_PROGRESS);

        fileNum++;
      }

      await _userRepository.setLastUpdateTime(Timestamp.fromDate(DateTime.now()).millisecondsSinceEpoch);

      yield HomeReadyState();
    } catch (e) {
      debugPrint("-- HomeBloc | Downloading the entire songbook error : $e");
      yield HomeFailureState(message: "Błąd podczas pobierania plików");
    }
  }

  Stream<HomeState> _mapHomeDownloadMissingFilesFilesEventToState(List<DatabaseLyricsFileInfo> newCloudFiles) async* {
    yield HomeShowLoadingState(message: "Pobieram teksty z biblioteki...", loadingType: LoadingType.CLOUD_PROGRESS);

    try {
      int count = newCloudFiles.length;
      int fileNum = 1;

      for (var fileInfo in newCloudFiles) {
        final Directory systemDir = await FilesUtils.getSongbookDirectory();
        final String fullPath = "${systemDir.path}/${fileInfo.localPath}";

        await downloadFile(uri: fileInfo.downloadUrl, fullPath: fullPath, count: count, current: fileNum);
        yield HomeShowLoadingState(message: "Pobieranie $fileNum / $count", loadingType: LoadingType.CLOUD_PROGRESS);

        fileNum++;
      }

      await _userRepository.setLastUpdateTime(Timestamp.fromDate(DateTime.now()).millisecondsSinceEpoch);

      yield HomeReadyState();
    } catch (e) {
      debugPrint("-- HomeBloc | Downloading missing files error : $e");
      yield HomeFailureState(message: "Błąd podczas pobierania plików");
    }
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

  Stream<HomeState> _mapHomeCheckForDeletedFilesEventToState(String groupId) async* {
    // final int lastUpdate = await _userRepository.getLastUpdateTime();
    // final List<UpdateInfo> updates = await _databaseRepository.getUpdatedFiles(groupId, lastUpdate);
    //
    // if (updates.isNotEmpty) {
    //   yield HomeNeedToUpdateSongbookState(updates: updates);
    // }

    // TODO : Check for deleted files, and delete them locally
  }

  Stream<HomeState> _mapHomeUpdateSongbookEventToState(List<DeletedFiles> updates) async* {
    yield HomeShowLoadingState(message: "Pobieranie...", loadingType: LoadingType.CLOUD_PROGRESS);

    try {
      List<DatabaseLyricsFileInfo> list = List();

      updates.forEach((element) {
        element.files.forEach((map) {
          list.add(DatabaseLyricsFileInfo.fromEntity(DatabaseLyricsFileInfoEntity.fromMap(map)));
        });
      });

      int fileNum = 1;
      int count = list.length;

      for (var fileInfo in list) {
        final Directory systemDir = await FilesUtils.getSongbookDirectory();
        final String fullPath = "${systemDir.path}/${fileInfo.localPath}";

        await downloadFile(uri: fileInfo.downloadUrl, fullPath: fullPath, count: count, current: fileNum);

        yield HomeShowLoadingState(message: "Pobieranie $fileNum / $count", loadingType: LoadingType.CLOUD_PROGRESS);

        fileNum++;
      }

      await _userRepository.setLastUpdateTime(Timestamp.fromDate(DateTime.now()).millisecondsSinceEpoch);

      yield HomeSongbookUpdateSuccessState();
    } catch (e) {
      debugPrint("-- HomeBloc | Updating songbook error : $e");
      yield HomeFailureState(message: "Błąd podczas aktualizacji śpiewnika");
    }
  }

  Stream<HomeState> _mapHomeGroupConfiguredEventToState(Group group) async* {
    yield HomeGroupConfiguredState(group: group);
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
      print(element.fileName());
    });

    result = allFiles.where((file) => file.fileName().toLowerCase().contains(fileName.toLowerCase())).toList();

    yield HomeSearchResultState(searchResult: result);
  }

  Stream<HomeState> _mapHomeUploadSongbookToCloudEventToState() async* {
    yield HomeShowLoadingState(message: "Udostępniam pliki grupie...", loadingType: LoadingType.CLOUD_PROGRESS);

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
            .map((e) => {'name': e.fileNameWithExtension, 'downloadUrl': e.downloadUrl, 'localPath': e.localPath})
            .toList(),
      );

      await _userRepository.setLastUpdateTime(Timestamp.fromDate(DateTime.now()).millisecondsSinceEpoch);

      yield HomeUploadSongbookSuccessState();
    } catch (e) {
      debugPrint("-- HomeBloc | Uploading the entire songbook error : $e");
      yield HomeFailureState(message : "Udostępnianie śpiewnika nie powiodło się");
    }
  }

  Stream<HomeState> _mapHomeUploadFilesToCloudEventToState(List<FileModel> newFiles) async* {
    yield HomeShowLoadingState(message: "Udostępniam pliki grupie...", loadingType: LoadingType.CLOUD_PROGRESS);

    try {
      User user = await _userRepository.currentUser();

      _storageRepository.setGroupId(user.groupId);

      List<Map<String, dynamic>> storageReferences =
          await _createReferenceList(newLocalFiles: newFiles, groupId: user.groupId);

      //_storageRepository.storageReferences.forEach((element) {debugPrint("StorageReference : ${element.keys}");});

      List<DatabaseLyricsFileInfo> uploadedFilesInfo = await _storageRepository.uploadFiles(storageReferences);

      await _groupRepository.setGroupShouldUpdateSongbook(user.uid, user.groupId);
      await _groupRepository.updateLyricsFilesInfo(uploadedFilesInfo, user.groupId);

      await _databaseRepository.addUpdateInfo(
        user.groupId,
        user.username,
        uploadedFilesInfo
            .map((e) => {'name': e.fileNameWithExtension, 'downloadUrl': e.downloadUrl, 'localPath': e.localPath})
            .toList(),
      );

      await _userRepository.setLastUpdateTime(Timestamp.fromDate(DateTime.now()).millisecondsSinceEpoch);

      yield HomeUploadSongbookSuccessState();
    } catch (e) {
      debugPrint("-- HomeBloc | Uploading files error : $e");
      yield HomeFailureState(message : "Wystąpił problem z udostępnieniem plików");
    }
  }

  Future<List<Map<String, dynamic>>> _createReferenceList({List<FileModel> newLocalFiles, String groupId}) async {
    String firebaseStoragePath = "";
    List<Map<String, dynamic>> storageReferences = List();

    _storageRepository.storageReferences.clear();

    for (var element in newLocalFiles) {
      String path = element.fileSystemEntity.path;
      String dir = path.substring(path.indexOf('/BandoSongbook/') + 15);

      debugPrint("firestoreStoragePath : $firebaseStoragePath \n   dri : $dir");

      firebaseStoragePath = "$dir";


      String reference;

      reference = "$groupId/songbook/$dir";

      print("Create new reference of file : ${element.fileSystemEntity.path} | Storage ref : $reference}");

      storageReferences.add({'reference': reference, 'file': File(element.fileSystemEntity.path)});
    }

    return storageReferences;
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
        _storageRepository.addStorageReference(File(element.path), subDir: firebaseStoragePath);
      }
    }
  }

  Stream<HomeState> _mapHomeLoadLocalSongbookEventToState() async* {
    yield HomeShowLoadingState(loadingType: LoadingType.LOADING);


    List<FileModel> songbook = List();

    try {
      debugPrint("Start Loading local songbook");
      Directory songbookDirectory = await FilesUtils.getSongbookDirectory();

      if (songbookDirectory.listSync().isNotEmpty) songbook = await FilesUtils.getFilesInPath(songbookDirectory.path);

      yield HomeLocalSongbookLoadedState(songbook: songbook);
    } catch (e) {
      debugPrint("-- HomeBloc | Getting local files error : $e");
      yield HomeFailureState(message : "Nie można załadować plików...");
    }
  }

  Stream<HomeState> _mapHomeCheckForNewLocalFilesEventToState() async* {
    List<FileModel> localSongbook = List();
    List<String> localNewFilesNames = List();
    List<String> cloudNewFilesNames = List();

    List<FileModel> localSongbookNewFiles = List();
    List<DatabaseLyricsFileInfo> cloudSongbookNewFiles = List();

    List<String> localFiles = List();
    List<String> cloudFiles = List();

    String groupId = await _userRepository.getUserGroupId();

    localSongbook = await FilesUtils.getBandoSongbookFiles();
    List<DatabaseLyricsFileInfo> cloudSongbook = await _groupRepository.getAllLyricsFilesInfo(groupId);

    localFiles = _getLocalSongbookFilesNames(localSongbook);
    cloudSongbook.forEach((element) {
      cloudFiles.add(element.fileNameWithExtension);
    });

    localNewFilesNames = localFiles.where((element) => !cloudFiles.contains(element)).toList();
    cloudNewFilesNames = cloudFiles.where((element) => !localFiles.contains(element)).toList();

    localSongbookNewFiles = _getNewLocalFiles(localNewFilesNames, localSongbook);
    cloudSongbookNewFiles =
        cloudSongbook.where((element) => cloudNewFilesNames.contains(element.fileNameWithExtension)).toList();

    debugPrint("localFiles : $localFiles");
    debugPrint("cloudFiles : $cloudFiles");
    localSongbookNewFiles.forEach((element) {
      debugPrint("localSongbookNewFiles : ${element.fileSystemEntity.path}");
    });
    cloudSongbookNewFiles.forEach((element) {
      debugPrint("cloudSongbookNewFiles : ${element.localPath}");
    });

    yield HomeCheckingSongbookCompleteState(newLocalFiles: localSongbookNewFiles, newCloudFiles: cloudSongbookNewFiles);
  }

  List<FileModel> _getNewLocalFiles(List<String> newFiles, List<FileModel> localSongbook) {
    List<FileModel> localSongbookNewFiles = List();

    localSongbook.forEach((element) {
      if (element.children.isNotEmpty) localSongbookNewFiles.addAll(_getNewLocalFiles(newFiles, element.children));

      if (!element.isDirectory && newFiles.contains(element.fileName())) localSongbookNewFiles.add(element);
    });

    return localSongbookNewFiles;
  }

  List<String> _getLocalSongbookFilesNames(List<FileModel> localSongbook) {
    List<String> allFilesNames = List();

    localSongbook.forEach((element) {
      if (element.children.isNotEmpty) {
        List<String> children = _getLocalSongbookFilesNames(element.children);
        allFilesNames.addAll(children);
      }
      if (!element.isDirectory) allFilesNames.add(element.fileName());
    });

    return allFilesNames;
  }
}
