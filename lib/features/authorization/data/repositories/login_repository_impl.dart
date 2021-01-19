import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/core/models/user_model.dart';
import 'package:bando/features/authorization/data/datasources/local_data_source.dart';
import 'package:bando/features/authorization/data/datasources/login_remote_data_source.dart';
import 'package:bando/features/authorization/domain/repositories/login_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

typedef Future<Either<Failure, UserModel>> _ActionChooser();

class LoginRepositoryImpl extends LoginRepository {
  final LoginRemoteDataSource _loginDataSource;
  final LocalDataSourceImpl _localDataSource;

  LoginRepositoryImpl({@required LoginRemoteDataSource loginDataSource, @required LocalDataSource localDataSource})
      : assert(loginDataSource != null),
        assert(localDataSource != null),
        _loginDataSource = loginDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword(EmailAddress email, Password password) async {
    return await _process(() => _loginDataSource.signInWithEmailAndPassword(email, password));
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    return await _process(() => _loginDataSource.signInWithGoogle());
  }

  Future<Either<Failure, User>> _process(_ActionChooser actionChooser) async {
    try {
      final eitherAction = await actionChooser();
      return eitherAction.fold(
        (failure) {
          return Left(failure);
        },
        (user) {
          _localDataSource.cacheUserInfo(user);
          return (user.groupId == '') ? Left(UnconfiguredGroup(user: user)) : Right(user);
        },
      );
    } on Exception {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword(EmailAddress email) async {
    try {
      final eitherResetPass = await _loginDataSource.resetPassword(email);
      return eitherResetPass.fold(
        (failure) => Left(SendingResetPasswordEmailFailure()),
        (success) => Right(unit),
      );
    } on Exception {
      return Left(SendingResetPasswordEmailFailure());
    }
  }
}
