
import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/authorization/data/datasources/local_data_source.dart';
import 'package:bando/features/authorization/data/datasources/login_remote_data_source.dart';
import 'package:bando/features/authorization/data/models/user_model.dart';
import 'package:bando/features/authorization/data/repositories/login_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockLoginRemoteDataSource extends Mock implements LoginRemoteDataSourceImpl {}
class MockLocalDataSource extends Mock implements LocalDataSourceImpl {}

void main() {
  EmailAddress email;
  Password password;
  LoginRepositoryImpl repository;
  UserModel user;
  MockLoginRemoteDataSource remoteDataSource;
  MockLocalDataSource localDataSource;

  setUp(() {
    remoteDataSource = MockLoginRemoteDataSource();
    localDataSource = MockLocalDataSource();
    repository = LoginRepositoryImpl(loginDataSource: remoteDataSource, localDataSource: localDataSource);
    password = Password(value: 'pass123');
    email = EmailAddress(value: 'test@email.com');
    user = UserModel(uid: 'TestUid', displayName: 'TestName', groupId: 'TestGroupId');
  });

  group('LoginRepositoryImpl tests - ', () {
    test('should return UserModel created from Firebase User when user sign in using email and password ', () async {
      when(remoteDataSource.signInWithEmailAndPassword(email, password)).thenAnswer((_) async => Right(user));
      when(localDataSource.cacheUserInfo(user)).thenAnswer((_) async => true);

      final resultUser = await repository.signInWithEmailAndPassword(email, password);

      expect(resultUser, Right(user));

      verify(remoteDataSource.signInWithEmailAndPassword(email, password));
      verify(localDataSource.cacheUserInfo(user));
      verifyNoMoreInteractions(remoteDataSource);
      verifyNoMoreInteractions(localDataSource);
    });

    test('should return ServerFailure when user tries to sign in using email and password', () async {
      when(remoteDataSource.signInWithEmailAndPassword(email, password)).thenThrow(Exception());

      final result = await repository.signInWithEmailAndPassword(email, password);

      expect(result, Left(ServerFailure()));

      verify(remoteDataSource.signInWithEmailAndPassword(email, password));
      verifyNoMoreInteractions(remoteDataSource);
      verifyNoMoreInteractions(localDataSource);
    });
  });

}