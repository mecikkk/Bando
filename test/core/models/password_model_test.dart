import 'package:bando/core/errors/failure.dart';
import 'package:bando/core/models/password_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('Password test - ', () {
    test('should create Password object with correct password', () {
      final password = PasswordModel(password: 'pass1234');
      expect(password.password, isA<String>());
      expect(password, isA<PasswordModel>());
    });

    test('should throw PasswordFailure exception with \'At least 6 characters, and one digit\' message', () {
      expect(() => PasswordModel(password: 'pass1'), throwsA(isInstanceOf<PasswordFailure>()));
      expect(() => PasswordModel(password: 'pass1'),
          throwsA(PasswordFailure(message: 'At least 6 characters, and one digit')));
    });

    test('should throw PasswordFailure exception with \'Password can\'t be empty\' message', () {
      expect(() => PasswordModel(password: ''), throwsA(isInstanceOf<PasswordFailure>()));
      expect(() => PasswordModel(password: ''), throwsA(PasswordFailure(message: 'Password can\'t be empty')));
    });
  });
}
