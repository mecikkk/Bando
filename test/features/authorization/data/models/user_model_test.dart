import 'package:bando/core/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

import 'file:///D:/Android/Bando/FlutterProject/bando/lib/core/models/user_model.dart';

void main() async {
  final userModel = UserModel(uid: 'TestUid', displayName: 'TestName', groupId: 'TestGroupId');
  group('UserModel tests - ', () {
    test('should be a subclass of User entity', () {
      expect(userModel, isA<User>());
    });
  });
}
