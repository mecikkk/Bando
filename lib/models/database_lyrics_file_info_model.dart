
import 'package:bando/entities/database_lyrics_file_info_entity.dart';
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
    return "UpdateInfo(fileName : $fileNameWithExtension, downloadUrl : $downloadUrl, localPath : $localPath)";
  }

  DatabaseLyricsFileInfoEntity toEntity() {
    return DatabaseLyricsFileInfoEntity(fileNameWithExtension, downloadUrl, localPath);
  }

  static DatabaseLyricsFileInfo fromEntity(DatabaseLyricsFileInfoEntity entity) {
    return DatabaseLyricsFileInfo(
      downloadUrl : entity.downloadUrl,
      fileNameWithExtension: entity.fileName,
      localPath: entity.localPath
    );
  }
}