import 'package:bando/auth/entities/user_entity.dart';

class User {

  String uid;
  String groupId;
  final String username;
  final bool shouldUpdateFiles;
  final int lastUpdate;

  User(this.uid, {this.username = 'User', this.groupId = '', this.shouldUpdateFiles = false, this.lastUpdate = 0});

  User copyWith({String uid, String username, String groupId, bool shouldUpdateFiles, int lastUpdate}) {
    return User(
      uid ?? this.uid,
      username : username ?? this.username,
      groupId: groupId ?? this.groupId,
      shouldUpdateFiles: shouldUpdateFiles ?? this.shouldUpdateFiles,
      lastUpdate: lastUpdate ?? this.lastUpdate
    );
  }

  @override
  int get hashCode => uid.hashCode ^ username.hashCode ^ groupId.hashCode ^ shouldUpdateFiles.hashCode;


  @override
  bool operator ==(other) =>
      identical(this, other) ||
      other is User &&
        runtimeType == other.runtimeType &&
        uid == other.uid &&
        username == other.username &&
        groupId == other.groupId &&
        shouldUpdateFiles == other.shouldUpdateFiles &&
        lastUpdate == other.lastUpdate;


  @override
  String toString() {
    return "User(uid : $uid, username : $username, groupId : $groupId, shouldUpdateFiles : $shouldUpdateFiles, lastUpdate : $lastUpdate)";
  }

  UserEntity toEntity() {
    return UserEntity(uid, username, groupId, shouldUpdateFiles, lastUpdate);
  }

  static User fromEntity(UserEntity entity) {
    return User(
      entity.uid,
      username : entity.username,
      groupId : entity.groupId,
      shouldUpdateFiles: entity.shouldUpdateFiles,
      lastUpdate: entity.lastUpdate
    );
  }
}