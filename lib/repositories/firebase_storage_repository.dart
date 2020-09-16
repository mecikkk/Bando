import 'dart:io';

import 'package:bando/models/database_lyrics_file_info_model.dart';
import 'package:bando/models/file_model.dart';
import 'package:bando/utils/files_utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

class FirebaseStorageRepository {
  String _groupId;
  List<Map<String, dynamic>> storageReferences = List();

  void setGroupId(String id) {
    _groupId = id;
  }

  Future<List<DatabaseLyricsFileInfo>> uploadAllFiles() async {
    List<DatabaseLyricsFileInfo> downloadUrls = List();

    try {
      for (var map in storageReferences) {
        StorageReference ref = FirebaseStorage.instance.ref().child("${map['reference']}");
        StorageTaskSnapshot task = await ref.putFile(map['file']).onComplete;

        File fileTmp = (map['file'] as File);
        String localPath = fileTmp.path.substring(fileTmp.path.lastIndexOf('/BandoSongbook') + 15);

        debugPrint("LocalPath test : $localPath");

        String downloadUrl = await task.ref.getDownloadURL();
        downloadUrls.add(new DatabaseLyricsFileInfo(
            fileNameWithExtension: basename(fileTmp.path), downloadUrl: downloadUrl, localPath: localPath));
        print("UPLOADING | Add new download url : $downloadUrl");
      }

      print("End of uploading files");
      return downloadUrls;
    } catch (e) {
      print("StorageRepository error : $e");
      return null;
    }
  }

  Future<List<DatabaseLyricsFileInfo>> uploadFiles(List<Map<String, dynamic>> references) async {
    List<DatabaseLyricsFileInfo> downloadUrls = List();

    try {
      for (var map in references) {
        StorageReference ref = FirebaseStorage.instance.ref().child("${map['reference']}");
        StorageTaskSnapshot task = await ref.putFile(map['file']).onComplete;

        File fileTmp = (map['file'] as File);
        String localPath = fileTmp.path.substring(fileTmp.path.lastIndexOf('/BandoSongbook') + 15);

        debugPrint("LocalPath test : $localPath");

        String downloadUrl = await task.ref.getDownloadURL();
        downloadUrls.add(new DatabaseLyricsFileInfo(
            fileNameWithExtension: basename(fileTmp.path), downloadUrl: downloadUrl, localPath: localPath));
        print("UPLOADING | Add new download url : $downloadUrl");
      }

      print("End of uploading files");
      return downloadUrls;
    } catch (e) {
      debugPrint("StorageRepository error : $e");
      return null;
    }
  }

  void addStorageReference(File file, {String subDir = ""}) {
    String reference;

    if (subDir != "")
      reference = "$_groupId/songbook/$subDir/${basename(file.path)}";
    else
      reference = "$_groupId/songbook/${basename(file.path)}";

    print("Create new reference of file : ${file.path} | Storage ref : $reference}");

    storageReferences.add({'reference': reference, 'file': file});
  }

  void addSingleStorageReference(File file, String path) {
    String reference;

    reference = "$_groupId/songbook/$path";

    print("Create new reference of file : ${file.path} | Storage ref : $reference}");

    storageReferences.add({'reference': reference, 'file': file});
  }

  Future<List<Map<String, dynamic>>> deleteFilesFromCloud(List<FileModel> deletedFiles, String groupId) async {

    List<Map<String, dynamic>> deletionInfo = List();

    try {
      for (var file in deletedFiles) {
        debugPrint("$groupId/songbook/${FilesUtils.getFirestoreReferenceFromFileModel(file)}");
        String reference = "$groupId/songbook/${FilesUtils.getFirestoreReferenceFromFileModel(file)}";

        deletionInfo.add({
          'name' : file.fileName(),
          'localPath' : file.fileSystemEntity.path,
          'storageReference' : reference,
        });

        if(file.isDirectory)
          await _deleteFolderContents(reference);
        else
          await FirebaseStorage.instance.ref().child(reference).delete();

      }

      return deletionInfo;
    } catch (e) {
      print("-- StorageRepository | Deleting file error : $e");
      return null;
    }
  }

  Future _deleteFolderContents(String reference) async {
    StorageReference ref = FirebaseStorage.instance.ref().child(reference);

    ref.listAll().then((value) async {
      Map<dynamic, dynamic> allData = value;

      allData.forEach((key, value) {

        Map<dynamic, dynamic> directories;
        Map<dynamic, dynamic> files;

        if(key == 'prefixes') directories = value;
        if(key == 'items') files = value;

        directories?.forEach((key, value) async {
          debugPrint("Directory : $key | ${value['path']}");
          await _deleteFolderContents(value['path']);
        });

        files?.forEach((key, value) async {
          debugPrint("File : $key | ${value['path']}");
          await _deleteFile(value['path']);
        });
      });
    });

    return;
  }

  Future _deleteFile(String filePath) async {
    debugPrint("DELETE FROM STORAGE: $filePath");

    return await FirebaseStorage.instance.ref().child(filePath).delete();
  }

}
