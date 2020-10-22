import 'package:bando/core/errors/failure.dart';
import 'package:bando/core/models/email_address_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  EmailAddressModel correctEmailAddress;

  group('Email tests - ', () {
    test('should create EmailAddresModel object with valid email address', () {
      correctEmailAddress = EmailAddressModel(emailAddress: 'valid@email.com');

      expect(correctEmailAddress.email, isA<String>());
      expect(correctEmailAddress.email, 'valid@email.com');
    });

    test('should throw EmailAddresFailure when email address is invalid', () {
      expect(() => new EmailAddressModel(emailAddress: 'invalid@email'), throwsA(isInstanceOf<EmailAddressFailure>()));
      expect(() => new EmailAddressModel(emailAddress: 'some.email.com'), throwsA(isInstanceOf<EmailAddressFailure>()));
    });
  });
}
