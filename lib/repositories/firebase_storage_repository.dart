import 'dart:io';

import 'package:bando/auth/models/update_file_info_model.dart';
import 'package:bando/file_manager/models/file_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';

class FirebaseStorageRepository {
  StorageReference _storageReference;
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
          fileName: basename(fileTmp.path),
          downloadUrl: downloadUrl,
          localPath: localPath
        ));
        print("UPLOADING | Add new download url : $downloadUrl");
      }

      print("End of uploading files");
      return downloadUrls;
    } catch (e) {
      print("StorageRepository error : $e");
      return null;
    }
  }

/*  Future<void> uploadFile(File file, {String subDir = ""}) async {
    if (subDir != "")
      _storageReference = FirebaseStorage.instance.ref().child("$_groupId/songbook/$subDir/${basename(file.path)}");
    else
      _storageReference = FirebaseStorage.instance.ref().child("$_groupId/songbook/${basename(file.path)}");
    print("repo upload file : ${file.path} | to : ${_storageReference.path}");
    StorageUploadTask task = _storageReference.putFile(file);
    await task.onComplete;

    String downloadUrl = await _storageReference.getDownloadURL();

    downloadUrls.add(downloadUrl);
  }*/

  void addStorageReference(File file, {String subDir = ""}) {
    String reference;

    if (subDir != "")
      reference = "$_groupId/songbook/$subDir/${basename(file.path)}";
    else
      reference = "$_groupId/songbook/${basename(file.path)}";

    print("Create new reference of file : ${file.path} | Storage ref : $reference}");

    storageReferences.add({'reference': reference, 'file': file});
  }

//  Future<List<dynamic>> getAllFiles(String groupId) async {
//    _storageReference = FirebaseStorage.instance
//        .ref()
//        .child(groupId).child('songbook');
//    return await _storageReference.listAll();
//  }

  Future<List<FileModel>> getAllFiles(String groupId) async {
    print("start getting all files");
    List<FileModel> allFiles = List();

    _storageReference = FirebaseStorage.instance
        .ref()
        .child(groupId).child('songbook');

    _storageReference.listAll().then((value) {
      if(value != null) {
        Map<dynamic, dynamic> map1 = value;
        map1.forEach((key, value) {
//          print("All elements : $key | $value");

          if(key == "prefixes") {
            // Directories
            Map<dynamic, dynamic> map2 = value;
            map2.forEach((key, value) {
              Map<dynamic, dynamic> fileInfo = value;
              fileInfo.forEach((key, value) {
                debugPrint("Directories : $key | $value");
              });
            });
          }

          if(key == "items") {
            // Files
            Map<dynamic, dynamic> map2 = value;
            map2.forEach((key, value) {
              Map<dynamic, dynamic> fileInfo = value;
              fileInfo.forEach((key, value) async {
                debugPrint("Items : $key | $value");
                if(key == "path") {
                  debugPrint("Storage item : ${await FirebaseStorage.instance.ref().child(value).getDownloadURL()}");
                }
              });
            });
          }

        });



      }
      // Zaglebienie mozna zrobic na podstawie rozszerzenia sciezki. Jak na koncu .pdf - to plik, jak nic - to folder
    });

    // TODO : Tutaj value wyrzuca Jsona z plikami, ale nie zaglebia sie w foldery..
    // TODO : Trzeba w momecie wrzucania wszystkiego do storage zapisywać downloadUrl do bazy danych (np. kolekcji grupy)

    print("getting all files end");
  }


}
