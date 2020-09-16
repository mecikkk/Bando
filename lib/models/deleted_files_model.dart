import 'package:bando/utils/files_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeletedFiles {
  final int time;
  final String whoDeleted;
  final List<Map<dynamic, dynamic>> files;

  DeletedFiles({
    @required this.time,
    @required this.whoDeleted,
    @required this.files,
  });

  DeletedFiles copyWith({String time, String whoUpdated, List<Map<dynamic, dynamic>> files}) {
    return DeletedFiles(
      time: time ?? this.time,
      whoDeleted: whoUpdated ?? this.whoDeleted,
      files: files ?? this.files,
    );
  }


  @override
  int get hashCode => time.hashCode ^ whoDeleted.hashCode ^ files.hashCode;

  @override
  bool operator ==(other) =>
      identical(this, other) ||
      other is DeletedFiles &&
          runtimeType == other.runtimeType &&
          time == other.time &&
          whoDeleted == other.whoDeleted &&
          files == other.files
  ;

  @override
  String toString() {
    return "DeletedFiles(time : $time (${Timestamp.fromMillisecondsSinceEpoch(time).toDate().toString()}), whoUpdated : $whoDeleted, files : $files)";
  }


  Map<String, Object> toJson() {
    return {
      "time": time,
      "whoDeleted": whoDeleted,
      "files": files
    };
  }

  static DeletedFiles fromMap(Map<dynamic, dynamic> json) {
    List<dynamic> files = json["files"] as List<dynamic>;
    List<Map<dynamic, dynamic>> allFiles = List();
    files.forEach((element) {
      allFiles.add(element);
    });

    return DeletedFiles(
        time: json["time"] as int,
        whoDeleted: json["whoDeleted"] as String,
        files: allFiles
    );
  }
}
