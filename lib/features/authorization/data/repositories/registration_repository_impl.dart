import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/authorization/data/datasources/local_data_source.dart';
import 'package:bando/features/authorization/data/datasources/registration_remote_data_source.dart';
import 'package:bando/features/authorization/domain/repositories/registration_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

class RegistrationRepositoryImpl extends RegistrationRepository {
  final RegistrationRemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;

  RegistrationRepositoryImpl(
      {@required RegistrationRemoteDataSource remoteDataSource, @required LocalDataSource localDataSource})
      : assert(remoteDataSource != null),
        assert(localDataSource != null),
        _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, User>> registerWithEmailAndPassword(
      EmailAddress email, Password password, String username) async {
    try {
      final eitherResult = await _remoteDataSource.registerWithEmailAndPassword(email, password, username);
      return eitherResult.fold(
        (failure) {
          return Left(failure);
        },
        (user) {
          _localDataSource.cacheUserInfo(user);
          return Right(user);
        },
      );
    } on Exception {
      return Left(ServerFailure());
    }
  }
}
