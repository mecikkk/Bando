import 'package:bando/core/entities/group.dart';
import 'package:bando/features/authorization/data/models/user_model.dart';
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

  @override
  List<Object> get props => [name, leaderId, members];

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

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> membersMap = List(
    );
    members.forEach(
            (element) {
          membersMap.add(
              {'uid': element.uid, 'displayName': element.displayName});
        });
    return {
      'name': name,
      'leaderId': leaderId,
      'members': membersMap,
    };
  }
// TODO : Ogarnac usecasey datasourcesy i repository
}
