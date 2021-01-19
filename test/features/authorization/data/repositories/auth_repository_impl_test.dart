import 'package:bando/core/errors/failure.dart';
import 'package:bando/core/models/user_model.dart';
import 'package:bando/features/authorization/data/datasources/auth_remote_data_source.dart';
import 'package:bando/features/authorization/data/repositories/auth_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockRemoteDataSource extends Mock implements AuthRemoteDataSourceImpl {}

void main() {
  AuthRepositoryImpl repository;
  UserModel user;
  MockRemoteDataSource remoteDataSource;

  setUp(() {
    remoteDataSource = MockRemoteDataSource();
    repository = AuthRepositoryImpl(remoteDataSource: remoteDataSource);
    user = UserModel(uid: 'TestUid', displayName: 'TestName', groupId: 'TestGroupId');
  });

  group('LoginRegisterRepository tests - ', () {

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
