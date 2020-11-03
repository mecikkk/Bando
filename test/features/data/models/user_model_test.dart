import 'package:bando/core/entities/user.dart';
import 'package:bando/features/authorization/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/firebase_auth_mock.dart';

void main() async {
  final userModel = UserModel(uid: 'TestUid', displayName: 'TestName', groupId: 'TestGroupId');
  final fUser = MockUser();

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
  });
}
