import 'dart:async';
import 'dart:io';

import 'package:bando/models/database_lyrics_file_info_model.dart';
import 'package:bando/models/deleted_files_model.dart';
import 'package:bando/models/file_model.dart';
import 'package:bando/models/group_model.dart';
import 'package:bando/models/user_model.dart';
import 'package:bando/repositories/firebase_storage_repository.dart';
import 'package:bando/repositories/firestore_group_repository.dart';
import 'package:bando/repositories/firestore_user_repository.dart';
import 'package:bando/repositories/realtime_database_repository.dart';
import 'package:bando/utils/files_utils.dart';
import 'package:bando/widgets/loading_widget.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
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
      yield* _mapHomeInitAppEventToState();
    } else if (event is HomeOnSearchFileEvent) {
      yield* _mapHomeOnSearchFileEventToState(event.fileName, event.songbook);
    } else if (event is HomeDownloadTheEntireSongbookEvent) {
      yield* _mapHomeDownloadTheEntireSongbookEventToState();
    } else if (event is HomeCheckForDeletedFilesEvent) {
      yield* _mapHomeCheckForDeletedFilesEventToState();
    } else if (event is HomeCheckForAnyUpdatesEvent) {
      yield* _mapHomeCheckForAnyUpdatesEventToState();
    } else if (event is HomeUploadFilesToCloudEvent) {
      yield* _mapHomeUploadFilesToCloudEventToState(event.newLocalFiles);
    } else if (event is HomeDownloadMissingFilesFilesEvent) {
      yield* _mapHomeDownloadMissingFilesFilesEventToState(event.newCloudFiles);
    } else if (event is HomeDeleteLocalFilesEvent) {
      yield* _mapHomeDeleteLocalFilesEventToState(event.deletedFiles);
    } else if (event is HomeDeleteFilesFromCloudEvent) {
      yield* _mapHomeDeleteFilesFromCloudEventToState(event.deletedFiles);
    }
  }

  Stream<HomeState> _mapHomeInitAppEventToState() async* {
    yield HomeShowLoadingState(loadingType: LoadingType.LOADING);

    try {

// Loading User personal info
      final SharedPreferences _pref = await SharedPreferences.getInstance();
      User user;
      Group group;
      // Load user and group basic information from shared pref. if is set up
      user = await _getUserInfo(_pref);
      group = await _getGroupInfo(_pref, groupId: user.groupId);

      if (user.groupId == '')
        yield HomeNoGroupState(user: user);
      else {

// Checking local songbook state
        List<FileModel> songbook = await FilesUtils.getBandoSongbookFiles();

        if (songbook.isEmpty) {
          var list = await _groupRepository.getAllLyricsFilesInfo(group.groupId);
          if (list.isEmpty)
            yield HomeNeedToUploadLocalSongbookToCloudState(user: user, group: group);
          else
            yield HomeNeedToDownloadTheEntireSongbookState(user: user, group: group);
        } else {
          yield HomeReadyState(songbook : songbook, user : user, group: group);
        }
      }
    } catch (e) {
      yield HomeFailureState();
      debugPrint("--- HomeInitAppEvent | Error in initial event : $e");
    }
  }

  Future<User> _getUserInfo(SharedPreferences pref) async {
    User user;

    if (pref.getString('username') == null || pref.getString('uid') == null) {
      debugPrint("Load USER info from firestore and store to shared pref");
      user = await _userRepository.currentUser();
      await pref.setString('username', user.username);
      await pref.setString('uid', user.uid);
      if (user.groupId != "") pref.setString('groupId', user.groupId);
    } else {
      debugPrint("Load USER info from shared pref");

      user = User(
        pref.getString('uid'),
        username: pref.getString('username'),
        groupId: pref.getString('groupId') ?? '',
      );
    }

    return user;
  }

  Future<Group> _getGroupInfo(SharedPreferences pref, {String groupId = ""}) async {
    Group group;
    if (groupId != '') {
      if (pref.getString('groupId') == null || pref.getString('groupName') == null) {
        debugPrint("Load GROUP info from firestore and store to shared pref");

        group = await _groupRepository.getGroup(groupId);
        pref.setString('groupName', group.name);
        pref.setString('groupId', group.groupId);
      } else {
        debugPrint("Load GROUP info from shared pref");

        group = Group(
          pref.getString('groupId'),
          name: pref.getString('groupName'),
        );
      }
    } else
      group = Group('');

    return group;
  }

  Stream<HomeState> _mapHomeDownloadTheEntireSongbookEventToState() async* {
    yield HomeShowLoadingState(message: "Pobieram teksty z biblioteki...", loadingType: LoadingType.CLOUD_PROGRESS);

    try {
      String groupId = await _userRepository.getCurrentUserGroupId();

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

      List<FileModel> songbook = await FilesUtils.getBandoSongbookFiles();

      yield HomeReloadSongbook(songbook: songbook);
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

      List<FileModel> songbook = await FilesUtils.getBandoSongbookFiles();

      yield HomeReloadSongbook(songbook: songbook);
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

  Stream<HomeState> _mapHomeCheckForDeletedFilesEventToState() async* {
    try {
      final int lastUpdate = await _userRepository.getLastUpdateTime();
      User user = await _userRepository.currentUser();

      List<DeletedFiles> deletedCloudFiles = await _databaseRepository.getDeletedFiles(user.groupId, lastUpdate);
      List<DeletedFiles> filesToDelete = List();


      deletedCloudFiles.forEach((element) {
        debugPrint("DELETES FROM REALTIME DB : ${element.whoDeleted} | ${element.files}");
      });

      List<FileModel> localFiles = await FilesUtils.getBandoSongbookFiles();

      List<String> localFilesPaths = _getLocalSongbookFilesPaths(localFiles);

      deletedCloudFiles = List.from(deletedCloudFiles.where((element) => (element.whoDeleted != user.username)));

      deletedCloudFiles.forEach((deletedFile) {
        List<Map<dynamic, dynamic>> files = List();

        deletedFile.files.forEach((file) {
          debugPrint("CloudDeletedFile : ${file['localPath']}");
          if (localFilesPaths.contains(file['localPath'])) files.add(file);
        });

        filesToDelete.add(DeletedFiles(time: deletedFile.time, whoDeleted: deletedFile.whoDeleted, files: files));
      });


      if (filesToDelete.isNotEmpty) {
        yield HomeNeedToDeleteFilesLocallyState(updates: filesToDelete);
      } else
        yield HomeStartCheckingUpdatesState();
    } catch (e) {
      debugPrint("-- HomeBloc | Checking for deleted files error : $e");
    }
  }

  Stream<HomeState> _mapHomeDeleteLocalFilesEventToState(List<DeletedFiles> deletedFiles) async* {
    yield HomeShowLoadingState(loadingType: LoadingType.LOADING);

    try {
      for (var deletedDetails in deletedFiles) {
        for (var file in deletedDetails.files) {
          await FilesUtils.deleteFile(fullPath: file['localPath']);
        }
      }

      await _userRepository.setLastUpdateTime(Timestamp.fromDate(DateTime.now()).millisecondsSinceEpoch);

      List<FileModel> songbook = await FilesUtils.getBandoSongbookFiles();

      yield HomeReloadSongbookAndHideUpdatesInfo(songbook : songbook);
    } catch (e) {
      debugPrint("-- HomeBloc | Deleting files error : $e");
      yield HomeFailureState(message: "Problem podczas usuwania zbędnych tekstów");
    }
  }

  Stream<HomeState> _mapHomeDeleteFilesFromCloudEventToState(List<FileModel> deletedFiles) async* {
    yield HomeShowLoadingState(message: "Usuwam pliki...", loadingType: LoadingType.CLOUD_PROGRESS);

    String groupId = await _userRepository.getCurrentUserGroupId();
    User user = await _userRepository.currentUser();

    List<Map<String, dynamic>> deletionInfo = List();
    try {
      deletionInfo = await _storageRepository.deleteFilesFromCloud(deletedFiles, groupId);

      await _groupRepository.deleteLyricsFilesInfo(deletedFiles, groupId);

      await _databaseRepository.addDeletionInfo(groupId, user.username, deletionInfo);

      for (var file in deletedFiles) {
        await FilesUtils.deleteFile(fullPath: file.fileSystemEntity.path);
      }

      await _userRepository.setLastUpdateTime(Timestamp.fromDate(DateTime.now()).millisecondsSinceEpoch);

      List<FileModel> songbook = await FilesUtils.getBandoSongbookFiles();

      yield HomeReloadSongbook(songbook: songbook);
    } catch (e) {
      debugPrint("-- HomeBloc | Deleting files from cloud error : $e");
      yield HomeFailureState(message: "Problem podczas usuwania tekstów w chmurze");
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
      print(element.fileName());
    });

    result = allFiles.where((file) => file.fileName().toLowerCase().contains(fileName.toLowerCase())).toList();

    yield HomeSearchResultState(searchResult: result);
  }


  Stream<HomeState> _mapHomeUploadFilesToCloudEventToState(List<FileModel> newFiles) async* {
    yield HomeShowLoadingState(message: "Udostępniam pliki grupie...", loadingType: LoadingType.CLOUD_PROGRESS);

    try {
      User user = await _userRepository.currentUser();

      _storageRepository.setGroupId(user.groupId);

      List<Map<String, dynamic>> storageReferences =
          await _createReferenceList(newLocalFiles: newFiles, groupId: user.groupId);

      List<DatabaseLyricsFileInfo> uploadedFilesInfo = await _storageRepository.uploadFiles(storageReferences);

      await _groupRepository.updateLyricsFilesInfo(uploadedFilesInfo, user.groupId);

      await _userRepository.setLastUpdateTime(Timestamp.fromDate(DateTime.now()).millisecondsSinceEpoch);

      yield HomeUploadSongbookSuccessState();
    } catch (e) {
      debugPrint("-- HomeBloc | Uploading files error : $e");
      yield HomeFailureState(message: "Wystąpił problem z udostępnieniem plików");
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

  Stream<HomeState> _mapHomeCheckForAnyUpdatesEventToState() async* {
    List<FileModel> localSongbook = List();
    List<String> localNewFilesPaths = List();
    List<String> cloudNewFilesPaths = List();

    List<FileModel> localSongbookNewFiles = List();
    List<DatabaseLyricsFileInfo> cloudSongbookNewFiles = List();

    List<String> localFiles = List();
    List<String> cloudFiles = List();

    String groupId = await _userRepository.getCurrentUserGroupId();

    localSongbook = await FilesUtils.getBandoSongbookFiles();
    List<DatabaseLyricsFileInfo> cloudSongbook = await _groupRepository.getAllLyricsFilesInfo(groupId);

    localFiles = _getLocalSongbookAsCloudPaths(localSongbook);

    cloudSongbook.forEach((element) {
      cloudFiles.add(element.localPath);
    });

    localNewFilesPaths = localFiles.where((element) => !cloudFiles.contains(element)).toList();
    cloudNewFilesPaths = cloudFiles.where((element) => !localFiles.contains(element)).toList();

    localSongbookNewFiles = _getNewLocalFiles(localNewFilesPaths, localSongbook);
    cloudSongbookNewFiles =
        cloudSongbook.where((element) => cloudNewFilesPaths.contains(element.localPath)).toList();


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

      if (!element.isDirectory && newFiles.contains(FilesUtils.getSongbookFilePath(element.fileSystemEntity.path)))
        localSongbookNewFiles.add(element);
    });

    return localSongbookNewFiles;
  }


  List<String> _getLocalSongbookFilesPaths(List<FileModel> localSongbook) {
    List<String> allFilesNames = List();

    localSongbook.forEach((element) {
      if (element.children.isNotEmpty) {
        List<String> children = _getLocalSongbookFilesPaths(element.children);
        allFilesNames.addAll(children);
      }
      if (!element.isDirectory) allFilesNames.add(element.fileSystemEntity.path);
    });

    return allFilesNames;
  }

  List<String> _getLocalSongbookAsCloudPaths(List<FileModel> localSongbook) {
    List<String> allFilesNames = List();

    localSongbook.forEach((element) {
      if (element.children.isNotEmpty) {
        List<String> children = _getLocalSongbookAsCloudPaths(element.children);
        allFilesNames.addAll(children);
      }
      if (!element.isDirectory) allFilesNames.add(FilesUtils.getSongbookFilePath(element.fileSystemEntity.path));
    });

    return allFilesNames;
  }
}
