import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/features/login/domain/repositories/login_repository.dart';
import 'package:bando/features/login/domain/usecases/sign_in_with_email_and_password.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockLoginRepository extends Mock implements LoginRepository {}

void main() {
  SignInWithEmailAndPassword emailPasswordUsecase;
  MockLoginRepository loginRepository;

  setUp(() {
    loginRepository = MockLoginRepository();
    emailPasswordUsecase = SignInWithEmailAndPassword(loginRepository);
  });

  final email = EmailAddress(email: 'test@test.com');
  final password = Password(password: 'pass123');

  final user = User(uid: 'testuid', displayName: 'TestUser', groupId: 'testGroupId');

  test('should return User object from the repository', () async {
    when(loginRepository.signInUserWithEmailAndPassword(email, password)).thenAnswer((_) async => Right(user));

    final result = await emailPasswordUsecase.call(email: email, password: password);

    expect(result, Right(user));

    verify(loginRepository.signInUserWithEmailAndPassword(email, password));
    verifyNoMoreInteractions(loginRepository);
  });
}
