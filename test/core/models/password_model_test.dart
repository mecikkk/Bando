import 'package:bando/core/entities/password.dart';
import 'package:bando/core/models/password_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Password test - ', () {
    test('should PasswordModel be a subclass of Password enitity', () {
      final password = PasswordModel(password: 'pass1234');
      expect(password.password, isA<String>());
      expect(password, isA<Password>());
    });
  });
}
