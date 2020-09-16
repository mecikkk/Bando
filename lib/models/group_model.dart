
import 'package:cloud_firestore/cloud_firestore.dart';

class Group {

  final String name;
  final String groupId;
  final List<Map<String, dynamic>> members;

  Group(this.groupId, {this.name = 'Group', this.members});

  Group copyWith({String groupId, String name, List<Map<String, dynamic>> members}) {
    return Group(
      groupId ?? this.groupId,
      name : name ?? this.name,
      members: members ?? this.members,
    );
  }

  @override
  int get hashCode => groupId.hashCode ^ name.hashCode ^ members.hashCode;


  @override
  bool operator == (other) =>
      identical(this, other) ||
          other is Group &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              groupId == other.groupId &&
              members == other.members;


  @override
  String toString() {
    return "Group(name : $name, groupId : $groupId, members : $members)";
  }


  Map<String, Object> toJson() {
    return {
      "name" : name,
      "members" : members,
    };
  }

  static Group fromJson(Map<String, Object> json) {
    return Group(
      json["groupId"] as String,
      name : json["name"] as String,
      members: json["members"] as List<Map<String, dynamic>>,
    );
  }

  static Group fromSnapshot(DocumentSnapshot snapshot) {
    return Group(
      snapshot.documentID,
      name : snapshot.data["name"],
      members : List<Map<String, dynamic>>.from(snapshot.data['members']),
    );
  }


  Map<String, Object> toDocument() {
    return {
      "name" : name,
      "members" : members
    };
  }
}