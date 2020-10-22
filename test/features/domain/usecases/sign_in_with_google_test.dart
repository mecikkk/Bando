import 'package:bando/core/entities/user.dart';
import 'package:bando/features/login/domain/repositories/login_repository.dart';
import 'package:bando/features/login/domain/usecases/sign_in_with_google.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockLoginRepository extends Mock implements LoginRepository {}

void main() {
  SignInWithGoogle googleUsecase;
  MockLoginRepository loginRepository;

  setUp(() {
    loginRepository = MockLoginRepository();
    googleUsecase = SignInWithGoogle(loginRepository);
  });

  final user = User(uid: 'testuid', displayName: 'TestUser', groupId: 'testGroupId');

  test('should return User object from the repository', () async {
    when(loginRepository.signInUserWithGoogle()).thenAnswer((_) async => Right(user));

    final result = await googleUsecase.call();

    expect(result, Right(user));

    verify(loginRepository.signInUserWithGoogle());
    verifyNoMoreInteractions(loginRepository);
  });
}
