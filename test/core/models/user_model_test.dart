import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/exceptions.dart';
import 'package:bando/core/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/firebase_auth_mock.dart';

void main() async {
  final userModel = UserModel(uid: 'TestUid', displayName: 'TestName', groupId: 'TestGroupId');
  final fUser = MockUser();
  final fNoClaimsUser = MockNoClaimsUser();

  group('UserModel tests - ', () {
    test('should be a subclass of User entity', () {
      expect(userModel, isA<User>());
    });

    test('should return UserModel created from Firebase User', () async {
      final user = await UserModel.fromFirebase(fUser);

      final token = await fUser.getIdTokenResult();

      expect(user.uid, fUser.uid);
      expect(user.displayName, fUser.displayName);
      expect(user.groupId, token.claims['groupId']);
    });

    test(
        'should throw UserClaimsException while creating UserModel from Firebase User when \'groupId\' claim isn\'t exist',
        () async {
      expect(() async => await UserModel.fromFirebase(fNoClaimsUser), throwsA(isInstanceOf<UserClaimsException>()));
    });
  });
}
