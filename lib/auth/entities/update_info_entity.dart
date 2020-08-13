import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';

class UpdateInfoEntity extends Equatable {
  final int time;
  final String whoUpdated;
  final String operation;
  final List<Map<dynamic, dynamic>> files;

  UpdateInfoEntity(
    this.time,
    this.whoUpdated,
    this.operation,
    this.files,
  );

  Map<String, Object> toJson() {
    return {
      "time": time,
      "whoUpdated": whoUpdated,
      "operation": operation,
      "files": files
    };
  }

  @override
  List<Object> get props => [time, whoUpdated, operation, files];

  @override
  String toString() {
    return 'UpdateInfoEntity(time : $time, whoUpdated : $whoUpdated, operation : $operation, files : $files)';
  }

  static UpdateInfoEntity fromJson(Map<String, dynamic> json) {
    return UpdateInfoEntity(
      json["time"] as int,
      json["whoUpdated"] as String,
      json["operation"] as String,
      json["files"] as List<Map<dynamic, dynamic>>
    );
  }

  static UpdateInfoEntity fromMap(Map<dynamic, dynamic> json) {
    List<dynamic> files = json["files"] as List<dynamic>;
    List<Map<dynamic, dynamic>> allFiles = List();
    files.forEach((element) {
      allFiles.add(element);
    });

    return UpdateInfoEntity(
        json["time"] as int,
        json["whoUpdated"] as String,
        json["operation"] as String,
        allFiles
    );
  }

  static UpdateInfoEntity fromSnapshot(DataSnapshot snapshot) {
    return UpdateInfoEntity(
        snapshot.value["time"] as int,
        snapshot.value["whoUpdated"] as String,
        snapshot.value["operation"] as String,
        snapshot.value["files"] as List<Map<dynamic, dynamic>>
    );
  }
}
