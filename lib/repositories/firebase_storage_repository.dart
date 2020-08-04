import 'dart:io';

import 'package:bando/auth/models/update_file_info_model.dart';
import 'package:bando/file_manager/models/file_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class FirebaseStorageRepository {
  StorageReference _storageReference;
  String _groupId;
  List<Map<String, dynamic>> storageReferences = List();

  void setGroupId(String id) {
    _groupId = id;
  }

  Future<List<UpdateFileInfo>> uploadAllFiles() async {
    List<UpdateFileInfo> downloadUrls = List();

    try {
      for (var map in storageReferences) {
        StorageReference ref = FirebaseStorage.instance.ref().child("${map['reference']}");
        StorageTaskSnapshot task = await ref.putFile(map['file']).onComplete;

        String downloadUrl = await task.ref.getDownloadURL();
        downloadUrls.add(new UpdateFileInfo(
          fileName: basename((map['file'] as File).path),
          downloadUrl: downloadUrl,
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
