import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String name;
  final String groupId;
  final String leaderID;
  final List<Map<String, dynamic>> members;

  Group(this.groupId, {this.leaderID = '', this.name = 'Group', this.members});

  Group copyWith({String groupId, String name, List<Map<String, dynamic>> members}) {
    return Group(
      groupId ?? this.groupId,
      leaderID: leaderID ?? this.leaderID,
      name: name ?? this.name,
      members: members ?? this.members,
    );
  }

  @override
  int get hashCode => groupId.hashCode ^ name.hashCode ^ members.hashCode ^ leaderID.hashCode;

  @override
  bool operator ==(other) =>
      identical(this, other) ||
      other is Group &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          leaderID == other.leaderID &&
          groupId == other.groupId &&
          members == other.members;

  @override
  String toString() {
    return "Group(name : $name, leaderId : $leaderID, groupId : $groupId, members : $members)";
  }

  Map<String, Object> toJson() {
    return {
      "name": name,
      "leaderId": leaderID,
      "members": members,
    };
  }

  static Group fromJson(Map<String, Object> json) {
    return Group(
      json["groupId"] as String,
      name: json["name"] as String,
      leaderID: json['leaderId'] as String,
      members: json["members"] as List<Map<String, dynamic>>,
    );
  }

  static Group fromSnapshot(DocumentSnapshot snapshot) {
    return Group(
      snapshot.id,
      name: snapshot.data()["name"],
      leaderID: snapshot.data()["leaderId"],
      members: List<Map<String, dynamic>>.from(snapshot.data()["members"]),
    );
  }

  Map<String, Object> toDocument() {
    return {"name": name, "leaderId": leaderID, "members": members};
  }
}
