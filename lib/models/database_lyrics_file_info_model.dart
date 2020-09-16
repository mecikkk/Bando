
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatabaseLyricsFileInfo {

  final String fileNameWithExtension;
  final String downloadUrl;
  final String localPath;

  DatabaseLyricsFileInfo({@required this.fileNameWithExtension,@required this.downloadUrl, @required this.localPath});

  DatabaseLyricsFileInfo copyWith({String fileName, String downloadUrl, String localPath}) {
    return DatabaseLyricsFileInfo(
      fileNameWithExtension : fileName ?? this.fileNameWithExtension,
      downloadUrl : downloadUrl ?? this.downloadUrl,
      localPath: localPath ?? this.localPath
    );
  }

  String fileName() => fileNameWithExtension;

  @override
  int get hashCode => downloadUrl.hashCode ^ fileNameWithExtension.hashCode ^ localPath.hashCode;

  @override
  bool operator == (other) =>
      identical(this, other) ||
          other is DatabaseLyricsFileInfo &&
              runtimeType == other.runtimeType &&
              fileNameWithExtension == other.fileNameWithExtension &&
              downloadUrl == other.downloadUrl &&
              localPath == other.localPath;


  @override
  String toString() {
    return "DatabaseLyricsFileInfo(fileName : $fileNameWithExtension, downloadUrl : $downloadUrl, localPath : $localPath)";
  }

  Map<String, Object> toJson() {
    return {
      "fileName" : fileNameWithExtension,
      "downloadUrl" : downloadUrl,
      "localPath" : localPath
    };
  }


  static DatabaseLyricsFileInfo fromMap(Map<dynamic, dynamic> json) {
    return DatabaseLyricsFileInfo(
        fileNameWithExtension : json["fileName"] as String,
        downloadUrl : json["downloadUrl"] as String,
        localPath : json["localPath"] as String
    );
  }

  static DatabaseLyricsFileInfo fromSnapshot(DocumentSnapshot snapshot) {
    return DatabaseLyricsFileInfo(
        fileNameWithExtension : snapshot.data["fileName"] as String,
        downloadUrl : snapshot.data["downloadUrl"] as String,
        localPath : snapshot.data["localPath"] as String
    );
  }
}