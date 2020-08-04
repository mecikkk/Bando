
import 'dart:io';

import 'package:bando/utils/util.dart';

class FileModel {

  final FileSystemEntity _fileSystemEntity;
  bool _isDirectory;
  final List<FileModel> children;

  FileModel(this._fileSystemEntity, [this.children = const <FileModel>[], this._isDirectory]){
    if(_isDirectory == null)
      _isDirectory = FileSystemEntity.isDirectorySync(_fileSystemEntity.path);
  }

  String getFileName() => _fileSystemEntity.name;

  FileSystemEntity get fileSystemEntity => _fileSystemEntity;

  bool get isDirectory => _isDirectory;

}