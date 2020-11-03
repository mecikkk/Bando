import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/authorization/data/repositories/auth_repository_impl.dart';
import 'package:bando/features/authorization/domain/usecases/register_with_email_and_password.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuthRepository extends Mock implements AuthRepositoryImpl {}

void main() {
  MockAuthRepository repository;
  RegisterWithEmailAndPassword usecase;

  setUp(() {
    repository = MockAuthRepository();
    usecase = RegisterWithEmailAndPassword(repository);
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

    test('should return LoginFailure with message \'Register error\' when unsuccessful register', () async {
      when(repository.registerWithEmailAndPassword(email, password, 'TestName'))
          .thenAnswer((_) async => Left(LoginFailure(message: 'Register error')));

      final result = await usecase.call(email, password, 'TestName');

      expect(result, Left(LoginFailure(message: 'Register error')));

      verify(repository.registerWithEmailAndPassword(email, password, 'TestName'));
      verifyNoMoreInteractions(repository);
    });

    test('should return LoginFailure with message \'Caching user info error\' when successful registered', () async {
      when(repository.registerWithEmailAndPassword(email, password, 'TestName'))
          .thenAnswer((_) async => Left(LoginFailure(message: 'Caching user info error')));

      final result = await usecase.call(email, password, 'TestName');

      expect(result, Left(LoginFailure(message: 'Caching user info error')));

      verify(repository.registerWithEmailAndPassword(email, password, 'TestName'));
      verifyNoMoreInteractions(repository);
    });
  });
}
