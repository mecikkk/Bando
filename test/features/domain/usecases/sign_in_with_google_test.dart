import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/authorization/data/repositories/auth_repository_impl.dart';
import 'package:bando/features/authorization/domain/usecases/sign_in_with_google.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuthRepository extends Mock implements AuthRepositoryImpl {}

void main() {
  SignInWithGoogle googleUsecase;
  MockAuthRepository authRepository;

  setUp(() {
    authRepository = MockAuthRepository();
    googleUsecase = SignInWithGoogle(authRepository);
  });

  final user = User(uid: 'testuid', displayName: 'TestUser', groupId: 'testGroupId');

  group('Usecase SignInWithGoogle - ', () {
    test('should return User object from the repository and cached it in SharedPreferences', () async {
      when(authRepository.signInWithGoogle()).thenAnswer((_) async => Right(user));

      final result = await googleUsecase.call();

      expect(result, Right(user));

      verify(authRepository.signInWithGoogle());
      verifyNoMoreInteractions(authRepository);
    });

    test('should throw LoginFailure with message \'Google signing in error\' from the repository on signing in',
        () async {
      when(authRepository.signInWithGoogle())
          .thenAnswer((_) async => Left(LoginFailure(message: 'Google signing in error')));

      final result = await googleUsecase.call();

      expect(result, Left(LoginFailure(message: 'Google signing in error')));

      verify(authRepository.signInWithGoogle());
      verifyNoMoreInteractions(authRepository);
    });

    test('should throw LoginFailure with message \'Caching user info error\' from the repository on caching use info',
        () async {
      when(authRepository.signInWithGoogle())
          .thenAnswer((_) async => Left(LoginFailure(message: 'Caching user info error')));

      final result = await googleUsecase.call();

      expect(result, Left(LoginFailure(message: 'Caching user info error')));

      verify(authRepository.signInWithGoogle());
      verifyNoMoreInteractions(authRepository);
    });
  });
}
