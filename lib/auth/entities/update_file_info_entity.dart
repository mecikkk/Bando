import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class DatabaseLyricsFileInfoEntity extends Equatable {

  final String fileName;
  final String downloadUrl;
  final String localPath;

  DatabaseLyricsFileInfoEntity(this.fileName,this.downloadUrl, this.localPath);

  Map<String, Object> toJson() {
    return {
      "fileName" : fileName,
      "downloadUrl" : downloadUrl,
      "localPath" : localPath
    };
  }

  @override
  List<Object> get props => [fileName, downloadUrl, localPath];

  @override
  String toString() {
    return 'UpdateInfoEntity(fileName : $fileName, downloadUrl : $downloadUrl, localPath : $localPath)';
  }

  static DatabaseLyricsFileInfoEntity fromMap(Map<dynamic, dynamic> json) {
    return DatabaseLyricsFileInfoEntity(
      json["fileName"] as String,
      json["downloadUrl"] as String,
      json["localPath"] as String
    );
  }

  static DatabaseLyricsFileInfoEntity fromSnapshot(DocumentSnapshot snapshot) {
    return DatabaseLyricsFileInfoEntity(
        snapshot.data["fileName"] as String,
        snapshot.data["downloadUrl"] as String,
        snapshot.data["localPath"] as String
    );
  }

}