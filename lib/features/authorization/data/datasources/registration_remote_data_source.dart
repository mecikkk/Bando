import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/core/utils/firebase_user_mapper.dart';
import 'package:bando/features/authorization/data/models/user_model.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

abstract class RegistrationRemoteDataSource {
  Future<Either<Failure, UserModel>> registerWithEmailAndPassword(
      EmailAddress email,
      Password password,
      String username,
      );
}

class RegistrationRemoteDataSourceImpl implements RegistrationRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  RegistrationRemoteDataSourceImpl({@required FirebaseAuth firebaseAuth})
      : assert(firebaseAuth != null),
        _firebaseAuth = firebaseAuth;

  @override
  Future<Either<Failure, UserModel>> registerWithEmailAndPassword(
      EmailAddress email, Password password, String username) async {
    try {
      final userCredential =
      await _firebaseAuth.createUserWithEmailAndPassword(email: email.value, password: password.value);

      User user = userCredential.user;

      await user.updateProfile(displayName: username);

      await user.reload();

      final bandoUser = await _firebaseAuth.currentUser.toDomain();
      return Right(bandoUser);
    } on FirebaseAuthException catch (e) {
      return (e.code == 'email-already-in-use') ? Left(EmailAlreadyInUse()) : Left(ServerFailure());
    }
  }

}
