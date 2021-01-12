import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class User extends Equatable {
  final String uid;
  final String displayName;
  final String groupId;

  User({
    @required this.uid,
    @required this.displayName,
    @required this.groupId,
  });

  @override
  List<Object> get props => [uid, displayName, groupId];

  @override
  String toString() {
    return 'User{uid: $uid, displayName: $displayName, groupId: $groupId}';
  }
}
