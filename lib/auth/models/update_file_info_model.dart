
import 'package:bando/auth/entities/update_file_info_entity.dart';
import 'package:flutter/material.dart';

class UpdateFileInfo {

  final String fileName;
  final String downloadUrl;

  UpdateFileInfo({@required this.fileName,@required this.downloadUrl});

  UpdateFileInfo copyWith({String fileName, String downloadUrl}) {
    return UpdateFileInfo(
      fileName : fileName ?? this.fileName,
      downloadUrl : downloadUrl ?? this.downloadUrl,
    );
  }

  @override
  int get hashCode => downloadUrl.hashCode ^ fileName.hashCode;


  @override
  bool operator == (other) =>
      identical(this, other) ||
          other is UpdateFileInfo &&
              runtimeType == other.runtimeType &&
              fileName == other.fileName &&
              downloadUrl == other.downloadUrl;


  @override
  String toString() {
    return "UpdateInfo(fileName : $fileName, downloadUrl : $downloadUrl)";
  }

  UpdateFileInfoEntity toEntity() {
    return UpdateFileInfoEntity(fileName, downloadUrl);
  }

  static UpdateFileInfo fromEntity(UpdateFileInfoEntity entity) {
    return UpdateFileInfo(
      downloadUrl : entity.downloadUrl,
      fileName: entity.fileName,
    );
  }
}