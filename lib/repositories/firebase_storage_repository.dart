import 'dart:io';

import 'package:bando/file_manager/models/file_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class FirebaseStorageRepository {
  StorageReference _storageReference;
  String _groupId;

  void setGroupId(String id) {
    _groupId = id;
  }

  Future<void> uploadFile(File file, {String subDir = ""}) async {
    if (subDir != "") _storageReference = FirebaseStorage.instance.ref().child("$_groupId/songbook/$subDir/${basename(file.path)}");
    else _storageReference = FirebaseStorage.instance.ref().child("$_groupId/songbook/${basename(file.path)}");
    print("repo upload file : ${file.path} | to : ${_storageReference.path}");
    StorageUploadTask task = _storageReference.putFile(file);
    await task.onComplete;
    return;

  }

  Future<List<FileModel>> getAllFiles(String groupId) async {
    print("start getting all files");
    _storageReference = FirebaseStorage.instance.ref().child(groupId);

    _storageReference.listAll().then((value) {
      print("All elements : $value");
    });

    // TODO : Tutaj value wyrzuca Jsona z plikami, ale nie zaglebia sie w foldery..
    // TODO : Trzeba w momecie wrzucania wszystkiego do storage zapisywać downloadUrl do bazy danych (np. kolekcji grupy)

    print("getting all files end");
  }
}
