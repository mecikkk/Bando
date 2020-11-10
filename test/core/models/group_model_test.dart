import 'dart:convert';
import 'dart:io';

import 'package:bando/core/entities/group.dart';
import 'package:bando/core/models/group_model.dart';
import 'package:bando/features/authorization/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/firebase_auth_mock.dart';

void main() {
  final groupModel = GroupModel(name: 'TestGroupName', leaderId: 'TestLeaderId', members: [
    UserModel(uid: 'TestUid1', displayName: 'TestName1', groupId: ''),
    UserModel(uid: 'TestUid2', displayName: 'TestName2', groupId: ''),
  ]);

  group('GroupModel tests - ', () {
    test('should be a subclass of Group entity', () {
      expect(groupModel, isA<Group>());
    });

    test('should return GroupModel created from Firebase document snapshot', () async {
      final groupJsonString = File('test/fixtures/group.json').readAsStringSync();
      final Map<String, dynamic> jsonMap = json.decode(groupJsonString);
      final doc = MockDocumentSnapshot(jsonMap);

      final group = GroupModel.fromSnapshot(doc);

      expect(group, groupModel);
      expect(group.name, groupModel.name);
      expect(group.leaderId, groupModel.leaderId);
      expect(group.members, groupModel.members);
    });

    test('should return Json created from GroupModel', () async {
      final groupJsonString = File('test/fixtures/group.json').readAsStringSync();
      final Map<String, dynamic> jsonMap = json.decode(groupJsonString);

      final jsonFromModel = groupModel.toJson();

      expect(jsonMap, jsonFromModel);
    });
  });
}
