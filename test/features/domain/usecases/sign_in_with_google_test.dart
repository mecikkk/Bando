import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/login_register/data/repositories/login_register_repository_impl.dart';
import 'package:bando/features/login_register/domain/repositories/login_register_repository.dart';
import 'package:bando/features/login_register/domain/usecases/sign_in_with_google.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockLoginRepository extends Mock implements LoginRegisterRepositoryImpl {}

void main() {
  SignInWithGoogle googleUsecase;
  MockLoginRepository loginRepository;

  setUp(() {
    loginRepository = MockLoginRepository();
    googleUsecase = SignInWithGoogle(loginRepository);
  });

  final user = User(uid: 'testuid', displayName: 'TestUser', groupId: 'testGroupId');

  group('Usecase SignInWithGoogle - ', () {
    test('should return User object from the repository and cached it in SharedPreferences', () async {
      when(loginRepository.signInWithGoogle()).thenAnswer((_) async => Right(user));

      final result = await googleUsecase.call();

      expect(result, Right(user));

      verify(loginRepository.signInWithGoogle());
      verifyNoMoreInteractions(loginRepository);
    });

    test('should throw LoginFailure with message \'Google signing in error\' from the repository on signing in',
        () async {
      when(loginRepository.signInWithGoogle())
          .thenAnswer((_) async => Left(LoginFailure(message: 'Google signing in error')));

      final result = await googleUsecase.call();

      expect(result, Left(LoginFailure(message: 'Google signing in error')));

      verify(loginRepository.signInWithGoogle());
      verifyNoMoreInteractions(loginRepository);
    });

    test('should throw LoginFailure with message \'Caching user info error\' from the repository on caching use info',
        () async {
      when(loginRepository.signInWithGoogle())
          .thenAnswer((_) async => Left(LoginFailure(message: 'Caching user info error')));

      final result = await googleUsecase.call();

      expect(result, Left(LoginFailure(message: 'Caching user info error')));

      verify(loginRepository.signInWithGoogle());
      verifyNoMoreInteractions(loginRepository);
    });
  });
}
