import 'package:bando/core/entities/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as FireAuth;
import 'package:flutter/foundation.dart';

class UserModel extends User {
  UserModel({
    @required String uid,
    @required String displayName,
    @required String groupId,
  }) : super(uid: uid, displayName: displayName, groupId: groupId);

  static Future<UserModel> fromFirebase(FireAuth.User fUser) async {
    FireAuth.IdTokenResult token = await fUser.getIdTokenResult();
    return UserModel(
      uid: fUser.uid ?? '',
      displayName: fUser.displayName ?? '',
      groupId: token.claims['groupId'] ?? '',
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      displayName: json['displayName'],
      groupId: json['groupId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'groupId': groupId,
    };
  }

  factory UserModel.mapAsMember(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      displayName: json['displayName'],
      groupId: '',
    );
  }

  Map<String, dynamic> toMember() {
    return {
      'uid': uid,
      'displayName': displayName,
    };
  }
}
