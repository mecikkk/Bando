import 'package:bando/entities/deleted_files_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeletedFiles {
  final int time;
  final String whoUpdated;
  final List<Map<dynamic, dynamic>> files;

  DeletedFiles({
    @required this.time,
    @required this.whoUpdated,
    @required this.files,
  });

  DeletedFiles copyWith({String time, String whoUpdated, List<Map<dynamic, dynamic>> files}) {
    return DeletedFiles(
      time: time ?? this.time,
      whoUpdated: whoUpdated ?? this.whoUpdated,
      files: files ?? this.files,
    );
  }

  @override
  int get hashCode => time.hashCode ^ whoUpdated.hashCode ^ files.hashCode;

  @override
  bool operator ==(other) =>
      identical(this, other) ||
      other is DeletedFiles &&
          runtimeType == other.runtimeType &&
          time == other.time &&
          whoUpdated == other.whoUpdated &&
          files == other.files
  ;

  @override
  String toString() {
    return "UpdateInfo(time : $time (${Timestamp.fromMillisecondsSinceEpoch(time).toDate().toString()}), whoUpdated : $whoUpdated, files : $files)";
  }

  DeletedFilesEntity toEntity() {
    return DeletedFilesEntity(time, whoUpdated, files);
  }

  static DeletedFiles fromEntity(DeletedFilesEntity entity) {
    return DeletedFiles(
      time: entity.time,
      whoUpdated: entity.whoUpdated,
      files: entity.files,
    );
  }
}
