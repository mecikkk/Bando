import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/authorization/data/repositories/login_repository_impl.dart';
import 'package:bando/features/authorization/domain/usecases/sign_in_with_email_and_password_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockLoginRepository extends Mock implements LoginRepositoryImpl {}

void main() {
  SignInWithEmailAndPasswordUseCase emailPasswordUsecase;
  MockLoginRepository loginRepository;

  setUp(() {
    loginRepository = MockLoginRepository();
    emailPasswordUsecase = SignInWithEmailAndPasswordUseCase(loginRepository);
  });

  final email = EmailAddress(value: 'test@test.com');
  final password = Password(value: 'pass123');

  final user = User(uid: 'testuid', displayName: 'TestUser', groupId: 'testGroupId');

  group('Usecase SignInWithEmailAndPassword - ', () {
    test('should return User object from the repository and cached it in SharedPreferences', () async {
      when(loginRepository.signInWithEmailAndPassword(email, password)).thenAnswer((_) async => Right(user));

      final result = await emailPasswordUsecase.call(email: email, password: password);

      expect(result, Right(user));

      verify(loginRepository.signInWithEmailAndPassword(email, password));
      verifyNoMoreInteractions(loginRepository);
    });

    test('should throw LoginFailure with message \'Signing in error\' from the repository on signing in', () async {
      when(loginRepository.signInWithEmailAndPassword(email, password))
          .thenAnswer((_) async => Left(LoginFailure(message: 'Signing in error')));

      final result = await emailPasswordUsecase.call(email: email, password: password);

      expect(result, Left(LoginFailure(message: 'Signing in error')));

      verify(loginRepository.signInWithEmailAndPassword(email, password));
      verifyNoMoreInteractions(loginRepository);
    });

    test('should throw LoginFailure with message \'Caching user info error\' from the repository on caching use info',
        () async {
      when(loginRepository.signInWithEmailAndPassword(email, password))
          .thenAnswer((_) async => Left(LoginFailure(message: 'Caching user info error')));

      final result = await emailPasswordUsecase.call(email: email, password: password);

      expect(result, Left(LoginFailure(message: 'Caching user info error')));

      verify(loginRepository.signInWithEmailAndPassword(email, password));
      verifyNoMoreInteractions(loginRepository);
    });
  });
}
