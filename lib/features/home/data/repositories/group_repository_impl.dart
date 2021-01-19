import 'package:bando/core/entities/group.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/core/utils/network_info.dart';
import 'package:bando/features/home/data/datasources/group_local_data_source.dart';
import 'package:bando/features/home/data/datasources/group_remote_data_source.dart';
import 'package:bando/features/home/domain/repositories/group_repository.dart';
import 'package:dartz/dartz.dart';

typedef Future<Either<Failure, Group>> _ActionChooser();

class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource _remoteDataSource;
  final GroupLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  GroupRepositoryImpl(this._remoteDataSource, this._localDataSource, this._networkInfo);

  @override
  Future<Either<Failure, Group>> getGroupById(String groupId) async {
    try {
      if (await _networkInfo.isConnected) {
        final either = await _remoteDataSource.getGroup(groupId);
        return either.fold(
              (failure) => Left(failure),
              (group) => Right(group),
        );
      } else {
        final group = await _localDataSource.getCachedGroupInfo();

        return Right(group);
      }
    } on Exception {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Group>> changeLeader(String newLeaderId) async {
    return await _process(() => _remoteDataSource.changeLeader(newLeaderId));
  }

  @override
  Future<Either<Failure, Group>> createNewGroup(User user, String groupName) async {
    return await _process(() => _remoteDataSource.createNewGroup(user, groupName));
  }

  @override
  Future<Either<Failure, Group>> joinToExistingGroup(User user, String groupId) async {
    return await _process(() => _remoteDataSource.joinToExistingGroup(user, groupId));
  }

  @override
  Future<Either<Failure, Group>> updateMemberData(User user) async {
    return await _process(() => _remoteDataSource.updateMemberData(user));
  }

  Future<Either<Failure, Group>> _process(_ActionChooser action) async {
    try {
      if (await _networkInfo.isConnected) {
        final either = await action();

        return either.fold(
          (failure) {
            return Left(failure);
          },
          (group) async {
            await _localDataSource.cacheGroupInfo(group);
            return Right(group);
          },
        );
      }
      return Left(NetworkConnectionFailure());
    } on Exception {
      return Left(ServerFailure());
    }
  }
}
