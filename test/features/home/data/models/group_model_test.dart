import 'dart:convert';
import 'dart:io';

import 'package:bando/core/models/user_model.dart';
import 'package:bando/features/home/data/models/group_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/firebase_auth_mock.dart';


main() {
  final groupModel = GroupModel(leaderId: "SomeFakeId", name: "SomeFakeName", members: [
    UserModel(uid: "SomeFakeUid1", displayName: "SomeFakeMemberName1", groupId: ''),
    UserModel(uid: "SomeFakeUid2", displayName: "SomeFakeMemberName2", groupId: ''),
  ]);

  test('should return a valid model created from DocumentSnapshot', () {
    //arrange
    final jsonString = File('test/fixtures/group.json').readAsStringSync();
    final jsonMap = json.decode(jsonString);
    final doc = MockDocumentSnapshot(jsonMap);

    //act
    final result = GroupModel.fromSnapshot(doc);
    //assert
    expect(result, groupModel);
  });

  test('should return a valid Json created from model', () {
    //arrange
    final jsonString = File('test/fixtures/group.json').readAsStringSync();
    final jsonMap = json.decode(jsonString);
    //act
    final result = groupModel.toJson();
    //assert
    expect(result, jsonMap);
  });
}
