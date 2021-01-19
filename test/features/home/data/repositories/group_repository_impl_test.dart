import 'package:bando/core/errors/exceptions.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/core/models/user_model.dart';
import 'package:bando/core/utils/network_info.dart';
import 'package:bando/features/home/data/datasources/group_local_data_source.dart';
import 'package:bando/features/home/data/datasources/group_remote_data_source.dart';
import 'package:bando/features/home/data/models/group_model.dart';
import 'package:bando/features/home/data/repositories/group_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockRemoteDataSource extends Mock implements GroupRemoteDataSource {}

class MockLocalDataSource extends Mock implements GroupLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  GroupRepositoryImpl repository;
  MockRemoteDataSource remoteDataSource;
  MockLocalDataSource localDataSource;
  MockNetworkInfo networkInfo;

  setUp(() {
    remoteDataSource = MockRemoteDataSource();
    localDataSource = MockLocalDataSource();
    networkInfo = MockNetworkInfo();
    repository = GroupRepositoryImpl(
      remoteDataSource,
      localDataSource,
      networkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(networkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(networkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('GroupRepositoryImpl tests - ', () {
    final user = UserModel(uid: "SomeFakeUid", displayName: "SomeFakeUsername", groupId: '');

    final newGroup = GroupModel(name: "SomeGroupName", leaderId: "SomeFakeUid", members: [user]);


    runTestsOnline(() {

      test('should return created group entity', () async {
        //arrange
        when(remoteDataSource.createNewGroup(user, "SomeGroupName")).thenAnswer((_) async => Right(newGroup));

        //act
        final result = await repository.createNewGroup(user, "SomeGroupName");
        //assert
        expect(result, Right(newGroup));
        verify(localDataSource.cacheGroupInfo(newGroup));
        verify(remoteDataSource.createNewGroup(user, "SomeGroupName"));
      });

      test('should return ServerFailure when try to create a new group', () async {
        //arrange
        when(remoteDataSource.createNewGroup(user, "SomeGroupName")).thenThrow(Exception());

        //act
        final result = await repository.createNewGroup(user, "SomeGroupName");
        //assert
        expect(result, Left(ServerFailure()));
        verifyZeroInteractions(localDataSource);
      });

    });

    runTestsOffline(() {
      test('should return ServerFailure when try to get cached group info', () async {
        //arrange
        when(localDataSource.getCachedGroupInfo()).thenThrow(CacheException());

        //act
        final result = await repository.getGroupById('SomeGroupId');
        //assert
        expect(result, Left(ServerFailure()));
      });

      test('should return NetworkConnectionFailure when try to create a new group', () async {
        //act

        final result = await repository.createNewGroup(user, "SomeGroupName");

        //assert
        expect(result, Left(NetworkConnectionFailure()));
        verifyZeroInteractions(localDataSource);
        verifyZeroInteractions(remoteDataSource);
      });

    });

  });
}
