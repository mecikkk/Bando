
import 'package:bando/auth/entities/update_file_info_entity.dart';
import 'package:flutter/material.dart';

class DatabaseLyricsFileInfo {

  final String fileName;
  final String downloadUrl;
  final String localPath;

  DatabaseLyricsFileInfo({@required this.fileName,@required this.downloadUrl, @required this.localPath});

  DatabaseLyricsFileInfo copyWith({String fileName, String downloadUrl, String localPath}) {
    return DatabaseLyricsFileInfo(
      fileName : fileName ?? this.fileName,
      downloadUrl : downloadUrl ?? this.downloadUrl,
      localPath: localPath ?? this.localPath
    );
  }

  @override
  int get hashCode => downloadUrl.hashCode ^ fileName.hashCode ^ localPath.hashCode;


  @override
  bool operator == (other) =>
      identical(this, other) ||
          other is DatabaseLyricsFileInfo &&
              runtimeType == other.runtimeType &&
              fileName == other.fileName &&
              downloadUrl == other.downloadUrl &&
              localPath == other.localPath;


  @override
  String toString() {
    return "UpdateInfo(fileName : $fileName, downloadUrl : $downloadUrl, localPath : $localPath)";
  }

  DatabaseLyricsFileInfoEntity toEntity() {
    return DatabaseLyricsFileInfoEntity(fileName, downloadUrl, localPath);
  }

  static DatabaseLyricsFileInfo fromEntity(DatabaseLyricsFileInfoEntity entity) {
    return DatabaseLyricsFileInfo(
      downloadUrl : entity.downloadUrl,
      fileName: entity.fileName,
      localPath: entity.localPath
    );
  }
}