import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/authorization/domain/repositories/registration_repository.dart';
import 'package:bando/features/authorization/domain/usecases/register_with_email_and_password_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockRegistrationRepository extends Mock implements RegistrationRepository {}

void main() {
  MockRegistrationRepository repository;
  RegisterWithEmailAndPasswordUseCase usecase;

  setUp(() {
    repository = MockRegistrationRepository();
    usecase = RegisterWithEmailAndPasswordUseCase(repository);
  });

  group('Usecase RegisterWithEmailAndPassword - ', () {
    final email = EmailAddress(value: 'valid@email.com');
    final password = Password(value: 'pass123');

    final user = User(uid: 'TestUid', displayName: 'TestName', groupId: 'TestGroupId');

    test('should return User when successful registered', () async {
      when(repository.registerWithEmailAndPassword(email, password, 'TestName')).thenAnswer((_) async => Right(user));

      final result = await usecase.call(email, password, 'TestName');

      expect(result, Right(user));

      verify(repository.registerWithEmailAndPassword(email, password, 'TestName'));
      verifyNoMoreInteractions(repository);
    });

    test('should return EmailAlreadyInUser failure when user tries to sign in', () async {
      when(repository.registerWithEmailAndPassword(email, password, 'TestName'))
          .thenAnswer((_) async => Left(EmailAlreadyInUse()));

      final result = await usecase.call(email, password, 'TestName');

      expect(result, Left(EmailAlreadyInUse()));

      verify(repository.registerWithEmailAndPassword(email, password, 'TestName'));
      verifyNoMoreInteractions(repository);
    });

  });
}
