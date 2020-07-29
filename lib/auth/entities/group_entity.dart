import 'package:bando/auth/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class GroupEntity extends Equatable {

  final String groupId;
  final String name;
  final List<Map<String, dynamic>> members;


  GroupEntity(this.groupId, this.name, this.members);

  Map<String, Object> toJson() {
    return {
      "name" : name,
      "members" : members,
    };
  }

  @override
  List<Object> get props => [groupId, name, members];

  @override
  String toString() {
    return 'GroupEntity(groupId : $groupId, name : $name, members : $members';
  }

  static GroupEntity fromJson(Map<String, Object> json) {
    return GroupEntity(
      json["groupId"] as String,
      json["name"] as String,
      json["members"] as List<Map<String, dynamic>>,
    );
  }

  static GroupEntity fromSnapshot(DocumentSnapshot snapshot) {
    return GroupEntity(
      snapshot.documentID,
      snapshot.data["name"],
      List.from(snapshot.data["members"]),
    );
  }

  Map<String, Object> toDocument() {
    return {
      "name" : name,
      "members" : members
    };
  }

}