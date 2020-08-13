import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable{

  final String uid;
  final String username;
  final String groupId;
  final bool shouldUpdateFiles;
  final int lastUpdate;

  const UserEntity(this.uid, this.username, this.groupId, this.shouldUpdateFiles, this.lastUpdate);

  Map<String, Object> toJson() {
    return {
      "username" : username,
      "groupId" : groupId,
      "shouldUpdateFiles" : shouldUpdateFiles,
      "lastUpdate" : lastUpdate
    };
  }

  @override
  List<Object> get props => [uid, username, groupId, shouldUpdateFiles, lastUpdate];

  @override
  String toString() {
    return 'UserModel(uid : $uid, username : $username, groupId : $groupId, shouldUpdateFiles : $shouldUpdateFiles, lastUpdate : $lastUpdate)';
  }

  static UserEntity fromJson(Map<String, Object> json) {
    return UserEntity(
      json["uid"] as String,
      json["username"] as String,
      json["groupId"] as String,
      json["shouldUpdateFiles"] as bool,
      json["lastUpdate"] as int
    );
  }

  static UserEntity fromSnapshot(DocumentSnapshot snapshot) {
    return UserEntity(
      snapshot.documentID,
      snapshot.data["username"],
      snapshot.data["groupId"],
      snapshot.data["shouldUpdateFiles"],
      snapshot.data["lastUpdate"]
    );
  }

  Map<String, Object> toDocument() {
    return {
      "username" : username,
      "groupId" : groupId,
      "shouldUpdateFiles" : shouldUpdateFiles,
      "lastUpdate" : lastUpdate
    };
  }

  Map<String, Object> toMap() {
    return {
      "uid" : uid,
      "username" : username,
      "shouldUpdateFiles" : shouldUpdateFiles,
      "lastUpdate" : lastUpdate
    };
  }

}