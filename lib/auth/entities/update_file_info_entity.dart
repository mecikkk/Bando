import 'package:equatable/equatable.dart';

class UpdateFileInfoEntity extends Equatable {

  final String fileName;
  final String downloadUrl;

  UpdateFileInfoEntity(this.fileName,this.downloadUrl);

  Map<String, Object> toJson() {
    return {
      "fileName" : fileName,
      "downloadUrl" : downloadUrl,
    };
  }

  @override
  List<Object> get props => [fileName, downloadUrl];

  @override
  String toString() {
    return 'UpdateInfoEntity(fileName : $fileName, downloadUrl : $downloadUrl';
  }

  static UpdateFileInfoEntity fromJson(Map<String, Object> json) {
    return UpdateFileInfoEntity(
      json["fileName"] as String,
      json["downloadUrl"] as String,
    );
  }

}