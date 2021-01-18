import 'package:bando/core/entities/user.dart';
import 'package:bando/features/authorization/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  final userModel = UserModel(uid: 'TestUid', displayName: 'TestName', groupId: 'TestGroupId');
  group('UserModel tests - ', () {
    test('should be a subclass of User entity', () {
      expect(userModel, isA<User>());
    });
  });
}
