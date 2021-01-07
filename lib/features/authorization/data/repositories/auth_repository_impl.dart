import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/authorization/data/datasources/auth_remote_data_source.dart';
import 'package:bando/features/authorization/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({@required AuthRemoteDataSource remoteDataSource})
      : assert(remoteDataSource != null),
        _remoteDataSource = remoteDataSource;


  @override
  Future<Either<Failure, User>> isLoggedIn() async {
    try {
      final user = await _remoteDataSource.isLoggedIn();
      return (user != null) ? Right(user) : Left(Unauthorized());
    } on Exception {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _remoteDataSource.logout();
      return Right(unit);
    } on Exception {
      return Left(ServerFailure());
    }
  }
}
