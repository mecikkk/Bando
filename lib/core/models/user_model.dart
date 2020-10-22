import 'package:bando/core/entities/user.dart';
import 'package:flutter/foundation.dart';

class UserModel extends User {
  UserModel({
    @required String uid,
    @required String displayName,
    @required String groupId,
  }) : super(uid: uid, displayName: displayName, groupId: groupId);

}
