import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/core/models/user_model.dart';
import 'package:bando/features/login_register/data/datasources/local_data_source.dart';
import 'package:bando/features/login_register/data/datasources/remote_data_source.dart';
import 'package:bando/features/login_register/domain/repositories/login_register_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

typedef Future<UserModel> _ActionChooser();

class LoginRegisterRepositoryImpl implements LoginRegisterRepository {
  final RemoteDataSourceImpl remoteDataSource;
  final LocalDataSourceImpl localDataSource;

  LoginRegisterRepositoryImpl({@required this.remoteDataSource, @required this.localDataSource});

  @override
  Future<Either<Failure, User>> registerWithEmailAndPassword(
      EmailAddress email, Password password, String username) async {
    return await process(() => remoteDataSource.registerWithEmailAndPassword(email, password, username));
  }

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword(EmailAddress email, Password password) async {
    return await process(() => remoteDataSource.signInWithEmailAndPassword(email, password));
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    return await process(() => remoteDataSource.signInWithGoogle());
  }

  Future<Either<Failure, User>> process(_ActionChooser actionChooser) async {
    try {
      final user = await actionChooser();
      localDataSource.cacheUserInfo(user);
      return Right(user);
    } on Exception {
      return Left(ServerFailure());
    }
  }
}
