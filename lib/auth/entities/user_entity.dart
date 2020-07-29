import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable{

  final String uid;
  final String username;
  final String groupId;
  final bool shouldUpdateFiles;

  const UserEntity(this.uid, this.username, this.groupId, this.shouldUpdateFiles);

  Map<String, Object> toJson() {
    return {
      "username" : username,
      "groupId" : groupId,
      "shouldUpdateFiles" : shouldUpdateFiles,
    };
  }

  @override
  List<Object> get props => [uid, username, groupId, shouldUpdateFiles];

  @override
  String toString() {
    return 'UserModel(uid : $uid, username : $username, groupId : $groupId, shouldUpdateFiles : $shouldUpdateFiles';
  }

  static UserEntity fromJson(Map<String, Object> json) {
    return UserEntity(
      json["uid"] as String,
      json["username"] as String,
      json["groupId"] as String,
      json["shouldUpdateFiles"] as bool,
    );
  }

  static UserEntity fromSnapshot(DocumentSnapshot snapshot) {
    return UserEntity(
      snapshot.documentID,
      snapshot.data["username"],
      snapshot.data["groupId"],
      snapshot.data["shouldUpdateFiles"],
    );
  }

  Map<String, Object> toDocument() {
    return {
      "username" : username,
      "groupId" : groupId,
      "shouldUpdateFiles" : shouldUpdateFiles
    };
  }

  Map<String, Object> toMap() {
    return {
      "uid" : uid,
      "username" : username,
      "shouldUpdateFiles" : shouldUpdateFiles
    };
  }

}