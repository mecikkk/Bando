
import 'package:cloud_firestore/cloud_firestore.dart';

class User {

  String uid;
  String groupId;
  final String username;
  final int lastUpdate;

  User(this.uid, {this.username = 'User', this.groupId = '', this.lastUpdate = 0});

  User copyWith({String uid, String username, String groupId, bool shouldUpdateFiles, int lastUpdate}) {
    return User(
      uid ?? this.uid,
      username : username ?? this.username,
      groupId: groupId ?? this.groupId,
      lastUpdate: lastUpdate ?? this.lastUpdate
    );
  }

  @override
  int get hashCode => uid.hashCode ^ username.hashCode ^ groupId.hashCode;


  @override
  bool operator ==(other) =>
      identical(this, other) ||
      other is User &&
        runtimeType == other.runtimeType &&
        uid == other.uid &&
        username == other.username &&
        groupId == other.groupId &&
        lastUpdate == other.lastUpdate;


  @override
  String toString() {
    return "User(uid : $uid, username : $username, groupId : $groupId, lastUpdate : $lastUpdate)";
  }

  Map<String, Object> toJson() {
    return {
      "username" : username,
      "groupId" : groupId,
      "lastUpdate" : lastUpdate
    };
  }

  static User fromJson(Map<String, Object> json) {
    return User(
        json["uid"] as String,
        username : json["username"] as String,
        groupId : json["groupId"] as String,
        lastUpdate: json["lastUpdate"] as int
    );
  }

  static User fromSnapshot(DocumentSnapshot snapshot) {
    return User(
        snapshot.documentID,
        username : snapshot.data["username"],
        groupId : snapshot.data["groupId"],
        lastUpdate : snapshot.data["lastUpdate"]
    );
  }

  Map<String, Object> toDocument() {
    return {
      "username" : username,
      "groupId" : groupId,
      "lastUpdate" : lastUpdate
    };
  }

  Map<String, Object> toMap() {
    return {
      "uid" : uid,
      "username" : username,
      "lastUpdate" : lastUpdate
    };
  }
}