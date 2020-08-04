import 'package:bando/auth/entities/update_info_entity.dart';
import 'package:flutter/material.dart';

class UpdateInfo {
  final String time;
  final String whoUpdated;
  final String operation;
  final List<Map<String, dynamic>> files;

  UpdateInfo({
    @required this.time,
    @required this.whoUpdated,
    @required this.operation,
    @required this.files,
  });

  UpdateInfo copyWith({String time, String whoUpdated, String operation, List<Map<String, dynamic>> files}) {
    return UpdateInfo(
      time: time ?? this.time,
      whoUpdated: whoUpdated ?? this.whoUpdated,
      operation: operation ?? this.operation,
      files: files ?? this.files,
    );
  }

  @override
  int get hashCode => time.hashCode ^ whoUpdated.hashCode ^ operation.hashCode ^ files.hashCode;

  @override
  bool operator ==(other) =>
      identical(this, other) ||
      other is UpdateInfo &&
          runtimeType == other.runtimeType &&
          time == other.time &&
          whoUpdated == other.whoUpdated &&
          operation == other.operation &&
          files == other.files
  ;

  @override
  String toString() {
    return "UpdateInfo(time : $time, whoUpdated : $whoUpdated, operation : $operation, files : $files)";
  }

  UpdateInfoEntity toEntity() {
    return UpdateInfoEntity(time, whoUpdated, operation,files);
  }

  static UpdateInfo fromEntity(UpdateInfoEntity entity) {
    return UpdateInfo(
      time: entity.time,
      whoUpdated: entity.whoUpdated,
      operation: entity.operation,
      files: entity.files,
    );
  }
}
