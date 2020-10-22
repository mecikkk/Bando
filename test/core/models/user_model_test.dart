import 'package:bando/core/entities/user.dart';
import 'package:bando/core/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final userModel = UserModel(uid: 'testUid', displayName: 'testName', groupId: 'testGroupId');

  test('should be a subclass of User entity', () {
    expect(userModel, isA<User>());
  });
}
