import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/core/models/user_model.dart';
import 'package:bando/features/login_register/data/datasources/local_data_source.dart';
import 'package:bando/features/login_register/data/datasources/remote_data_source.dart';
import 'package:bando/features/login_register/data/repositories/login_register_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../fixtures/firebase_auth_mock.dart';

class MockRemoteDataSource extends Mock implements RemoteDataSourceImpl {}

class MockLocalDataSource extends Mock implements LocalDataSourceImpl {}

void main() {
  EmailAddress email;
  Password password;
  LoginRegisterRepositoryImpl repository;
  UserModel user;
  MockRemoteDataSource remoteDataSource;
  MockLocalDataSource localDataSource;

  setUp(() {
    remoteDataSource = MockRemoteDataSource();
    localDataSource = MockLocalDataSource();
    repository = LoginRegisterRepositoryImpl(remoteDataSource: remoteDataSource, localDataSource: localDataSource);
    password = Password(password: 'pass123');
    email = EmailAddress(email: 'test@email.com');
    user = UserModel(uid: 'TestUid', displayName: 'TestName', groupId: 'TestGroupId');
  });

  group('LoginRegisterRepository tests - ', () {
    test('should return UserModel created from Firebase User when user sign in using email and password ', () async {
      when(remoteDataSource.signInWithEmailAndPassword(email, password)).thenAnswer((_) async => user);
      when(localDataSource.cacheUserInfo(user)).thenAnswer((_) async => true);

      final resultUser = await repository.signInWithEmailAndPassword(email, password);

      expect(resultUser, Right(user));

      verify(remoteDataSource.signInWithEmailAndPassword(email, password));
      verify(localDataSource.cacheUserInfo(user));
      verifyNoMoreInteractions(remoteDataSource);
      verifyNoMoreInteractions(localDataSource);
    });

    test('should throw ServerFailure when user tries to sign in using email and password', () async {
      when(remoteDataSource.signInWithEmailAndPassword(email, password))
          .thenAnswer((realInvocation) => throw ServerFailure());

      final call = repository.signInWithEmailAndPassword;

      expect(() => call(email, password), throwsA(isInstanceOf<ServerFailure>()));

      verify(remoteDataSource.signInWithEmailAndPassword(email, password));
      verifyNoMoreInteractions(remoteDataSource);
      verifyNoMoreInteractions(localDataSource);
    });
  });
}
