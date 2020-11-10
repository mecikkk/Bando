import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/authorization/data/datasources/auth_remote_data_source.dart';
import 'package:bando/features/authorization/data/datasources/local_data_source.dart';
import 'package:bando/features/authorization/data/models/user_model.dart';
import 'package:bando/features/authorization/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

typedef Future<Either<Failure, UserModel>> _ActionChooser();

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSourceImpl _remoteDataSource;
  final LocalDataSourceImpl _localDataSource;

  AuthRepositoryImpl({@required AuthRemoteDataSource remoteDataSource, @required LocalDataSource localDataSource})
      : assert(remoteDataSource != null),
        assert(localDataSource != null),
        _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, User>> registerWithEmailAndPassword(
      EmailAddress email, Password password, String username) async {
    return await _process(() => _remoteDataSource.registerWithEmailAndPassword(email, password, username));
  }

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword(EmailAddress email, Password password) async {
    return await _process(() => _remoteDataSource.signInWithEmailAndPassword(email, password));
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    return await _process(
            () =>
            _remoteDataSource.signInWithGoogle(
            ));
  }

  Future<Either<Failure, User>> _process(_ActionChooser actionChooser) async {
    try {
      final eitherAction = await actionChooser(
      );
      return eitherAction.fold(
            (failure) {
          return Left(
              failure);
        },
            (user) {
          _localDataSource.cacheUserInfo(
              user);
          return (user.groupId == '') ? Left(
              UnconfiguredGroup(
                  user: user)) : Right(
              user);
        },
      );
    } on Exception {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, User>> isLoggedIn() async {
    try {
      final user = await _remoteDataSource.isLoggedIn(
      );
      return (user != null) ? Right(
          user) : Left(
          Unauthorized(
          ));
    } on Exception {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _remoteDataSource.logout(
      );
      return Right(
          unit);
    } on Exception {
      return Left(
          ServerFailure(
          ));
    }
  }
}
