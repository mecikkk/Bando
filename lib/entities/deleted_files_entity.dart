import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';

class DeletedFilesEntity extends Equatable {
  final int time;
  final String whoUpdated;
  final List<Map<dynamic, dynamic>> files;

  DeletedFilesEntity(
    this.time,
    this.whoUpdated,
    this.files,
  );

  Map<String, Object> toJson() {
    return {
      "time": time,
      "whoUpdated": whoUpdated,
      "files": files
    };
  }

  @override
  List<Object> get props => [time, whoUpdated, files];

  @override
  String toString() {
    return 'UpdateInfoEntity(time : $time, whoUpdated : $whoUpdated, files : $files)';
  }

  static DeletedFilesEntity fromJson(Map<String, dynamic> json) {
    return DeletedFilesEntity(
      json["time"] as int,
      json["whoUpdated"] as String,
      json["files"] as List<Map<dynamic, dynamic>>
    );
  }

  static DeletedFilesEntity fromMap(Map<dynamic, dynamic> json) {
    List<dynamic> files = json["files"] as List<dynamic>;
    List<Map<dynamic, dynamic>> allFiles = List();
    files.forEach((element) {
      allFiles.add(element);
    });

    return DeletedFilesEntity(
        json["time"] as int,
        json["whoUpdated"] as String,
        allFiles
    );
  }

  static DeletedFilesEntity fromSnapshot(DataSnapshot snapshot) {
    return DeletedFilesEntity(
        snapshot.value["time"] as int,
        snapshot.value["whoUpdated"] as String,
        snapshot.value["files"] as List<Map<dynamic, dynamic>>
    );
  }
}
