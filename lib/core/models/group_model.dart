import 'package:bando/features/authorization/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class GroupModel extends Equatable {
  final String name;
  final String leaderId;
  final List<UserModel> members;

  GroupModel({@required this.name, @required this.leaderId, @required this.members});

  @override
  List<Object> get props => [name, leaderId, members];

  factory GroupModel.fromSnapshot(DocumentSnapshot doc) {
    final List<Map<String, dynamic>> membersMap = doc.data()['members'];
    final List<UserModel> members = membersMap.map((e) => UserModel.mapAsMember(e)).toList();

    return GroupModel(
      name: doc.data()['name'],
      leaderId: doc.data()['leaderId'],
      members: members,
    );
  }

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> membersMap = members.map((e) => e.toMember()).toList();
    return {
      'name': name,
      'leaderId': leaderId,
      'members': membersMap,
    };
  }
}
