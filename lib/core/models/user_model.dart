import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/exceptions.dart';
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
    if (token.claims['groupId'] == null || token.claims['groupId'] == '') throw UserClaimsException();
    return UserModel(
      uid: fUser.uid ?? 'Unknown user ID',
      displayName: fUser.displayName ?? 'Unknown User name',
      groupId: token.claims['groupId'],
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
}
