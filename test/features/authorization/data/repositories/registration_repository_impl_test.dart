import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/core/models/user_model.dart';
import 'package:bando/features/authorization/data/datasources/local_data_source.dart';
import 'package:bando/features/authorization/data/datasources/registration_remote_data_source.dart';
import 'package:bando/features/authorization/data/repositories/registration_repository_impl.dart';
import 'package:bando/features/authorization/domain/repositories/registration_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockLocalDataSource extends Mock implements LocalDataSource {}
class MockRepositoryRemoteDataSource extends Mock implements RegistrationRemoteDataSource {}


void main() {
  MockLocalDataSource localDataSource;
  MockRepositoryRemoteDataSource remoteDataSource;
  RegistrationRepository repository;

  setUp(() {
    localDataSource = MockLocalDataSource();
    remoteDataSource = MockRepositoryRemoteDataSource();
    repository = RegistrationRepositoryImpl(remoteDataSource: remoteDataSource, localDataSource: localDataSource);

  });

  group('RegistrationRepository - tests ', () {
    final email = EmailAddress(value: 'valid@email.com');
    final password = Password(value: 'pass123');
    final user = UserModel(uid: 'TestUid', displayName: 'TestName', groupId: 'TestGroupId');


    test('should return User object and store user info in Shared Preferences when registration is successful', () async {
      //arrange
      when(remoteDataSource.registerWithEmailAndPassword(email, password, 'TestUser')).thenAnswer((_) => Future.value(Right(user)));
      //act
      final result = await repository.registerWithEmailAndPassword(email, password, 'TestUser');
      //assert

      expect(result, Right(user));

      verify(remoteDataSource.registerWithEmailAndPassword(email, password, 'TestUser'));
      verify(localDataSource.cacheUserInfo(user));
      verifyNoMoreInteractions(remoteDataSource);
      verifyNoMoreInteractions(localDataSource);
    });

    test('should return EmailAlreadyInUse failure when user tries to register with the email address of an existing account', () async {
      //arrange
      when(remoteDataSource.registerWithEmailAndPassword(email, password, 'TestUser')).thenAnswer((_) => Future.value(Left(EmailAlreadyInUse())));
      //act
      final result = await repository.registerWithEmailAndPassword(email, password, 'TestUser');
      //assert

      expect(result, Left(EmailAlreadyInUse()));

      verify(remoteDataSource.registerWithEmailAndPassword(email, password, 'TestUser'));
      verifyNoMoreInteractions(remoteDataSource);
      verifyZeroInteractions(localDataSource);
    });
  });

}
