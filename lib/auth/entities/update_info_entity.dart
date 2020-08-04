import 'package:equatable/equatable.dart';

class UpdateInfoEntity extends Equatable {
  final String time;
  final String whoUpdated;
  final String operation;
  final List<Map<String, dynamic>> files;

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

  static UpdateInfoEntity fromJson(Map<String, Object> json) {
    return UpdateInfoEntity(
      json["time"] as String,
      json["whoUpdated"] as String,
      json["operation"] as String,
      json["files"] as List<Map<String, dynamic>>
    );
  }
}
