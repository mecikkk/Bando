import 'package:bando/core/entities/group.dart';
import 'package:bando/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class GroupModel extends Group {
  GroupModel({
    @required String name,
    @required String leaderId,
    @required List<UserModel> members,
  }) : super(
    leaderId: leaderId,
    name: name,
    members: members,
  );

  factory GroupModel.fromSnapshot(DocumentSnapshot doc) {
    final List<Map<String, dynamic>> membersMap = List();

    doc.data()['members'].forEach((element) {
      membersMap.add({'uid': element['uid'], 'displayName': element['displayName']});
    });

    final List<UserModel> members = membersMap.map((e) => UserModel.mapAsMember(e)).toList();

    return GroupModel(
      name: doc.data()['name'],
      leaderId: doc.data()['leaderId'],
      members: members,
    );
  }

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> membersMap = List();

    json['members'].forEach((element) {
      membersMap.add({'uid': element['uid'], 'displayName': element['displayName']});
    });

    final List<UserModel> members = membersMap.map((e) => UserModel.mapAsMember(e)).toList();

    return GroupModel(
      name: json['name'],
      leaderId: json['leaderId'],
      members: members,
    );
  }

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> membersMap = members.map((e) => {'uid' : e.uid, 'displayName' : e.displayName}).toList();

    return {
      'name': name,
      'leaderId': leaderId,
      'members': membersMap,
    };
  }
}
