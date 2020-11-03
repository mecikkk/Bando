import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/authorization/data/models/user_model.dart';
import 'package:bando/features/authorization/data/datasources/local_data_source.dart';
import 'package:bando/features/authorization/data/datasources/auth_remote_data_source.dart';
import 'package:bando/features/authorization/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

typedef Future<UserModel> _ActionChooser();

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSourceImpl remoteDataSource;
  final LocalDataSourceImpl localDataSource;

  AuthRepositoryImpl({@required this.remoteDataSource, @required this.localDataSource});

  @override
  Future<Either<Failure, User>> registerWithEmailAndPassword(
      EmailAddress email, Password password, String username) async {
    return await _process(() => remoteDataSource.registerWithEmailAndPassword(email, password, username));
  }

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword(EmailAddress email, Password password) async {
    return await _process(() => remoteDataSource.signInWithEmailAndPassword(email, password));
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    return await _process(() => remoteDataSource.signInWithGoogle());
  }

  Future<Either<Failure, User>> _process(_ActionChooser actionChooser) async {
    try {
      final user = await actionChooser();
      localDataSource.cacheUserInfo(user);
      if (user.groupId == '') return Left(UnconfiguredGroup(user: user));
      return Right(user);
    } on Exception {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, User>> isLoggedIn() async {
    try {
      final user = await remoteDataSource.isLoggedIn();
      return (user != null) ? Right(user) : Left(Unauthorized());
    } on Exception {
      return Left(ServerFailure());
    }
  }

  @override
  Future<void> loggOut() async {
    return await remoteDataSource.loggOut();
  }
}
