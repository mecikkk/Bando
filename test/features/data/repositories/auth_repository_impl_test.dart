import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/authorization/data/datasources/auth_remote_data_source.dart';
import 'package:bando/features/authorization/data/datasources/local_data_source.dart';
import 'package:bando/features/authorization/data/models/user_model.dart';
import 'package:bando/features/authorization/data/repositories/auth_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockRemoteDataSource extends Mock implements AuthRemoteDataSourceImpl {}

class MockLocalDataSource extends Mock implements LocalDataSourceImpl {}

void main() {
  EmailAddress email;
  Password password;
  AuthRepositoryImpl repository;
  UserModel user;
  MockRemoteDataSource remoteDataSource;
  MockLocalDataSource localDataSource;

  setUp(() {
    remoteDataSource = MockRemoteDataSource();
    localDataSource = MockLocalDataSource();
    repository = AuthRepositoryImpl(remoteDataSource: remoteDataSource, localDataSource: localDataSource);
    password = Password(value: 'pass123');
    email = EmailAddress(value: 'test@email.com');
    user = UserModel(uid: 'TestUid', displayName: 'TestName', groupId: 'TestGroupId');
  });

  group('LoginRegisterRepository tests - ', () {
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

    test('should return User entity when checks is logged in', () async {
      //arrange
      when(remoteDataSource.isLoggedIn()).thenAnswer((_) => Future.value(user));
      //act
      final result = await repository.isLoggedIn();

      //assert
      expect(result, equals(Right(user)));
    });

    test('should return Unauthorized when user is not logged in', () async {
      //arrange
      when(remoteDataSource.isLoggedIn()).thenAnswer((_) => Future.value(null));
      //act
      final result = await repository.isLoggedIn();

      //assert
      expect(result, equals(Left(Unauthorized())));
    });

    test('should return ServerFailure when checking logged in user throw an Exception', () async {
      //arrange
      when(remoteDataSource.isLoggedIn()).thenThrow(Exception());
      //act
      final result = await repository.isLoggedIn();

      //assert
      expect(result, Left(ServerFailure()));
    });

    test('should return Right(unit) object when logging out is successful', () async {
      //act
      final result = await repository.logout();
      //assert
      expect(result, Right(unit));
    });

    test('should return ServerFailure when logging out is failure', () async {
      when(remoteDataSource.logout()).thenThrow(Exception());
      //act
      final result = await repository.logout();
      //assert
      expect(result, Left(ServerFailure()));
    });
  });
}
