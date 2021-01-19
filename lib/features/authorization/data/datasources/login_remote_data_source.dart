import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/core/models/user_model.dart';
import 'package:bando/core/utils/firebase_user_mapper.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class LoginRemoteDataSource {
  Future<Either<Failure, UserModel>> signInWithEmailAndPassword(EmailAddress email, Password password);
  Future<Either<Failure, UserModel>> signInWithGoogle();
  Future<Either<Failure, Unit>> resetPassword(EmailAddress email);
}

class LoginRemoteDataSourceImpl extends LoginRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  LoginRemoteDataSourceImpl({@required FirebaseAuth firebaseAuth, @required GoogleSignIn googleSignIn})
      : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  @override
  Future<Either<Failure, UserModel>> signInWithEmailAndPassword(EmailAddress email, Password password) async {
    try {
      final userCredential =
      await _firebaseAuth.signInWithEmailAndPassword(email: email.value, password: password.value);

      final user = await userCredential.user.toDomain();
      return Right(user);
    } on FirebaseAuthException catch (e) {
      debugPrint('ERROR ${e.code} : ${e.message}');
      return (e.code == 'wrong-password' || e.code == 'user-not-found')
          ? Left(WrongEmailOrPassword())
          : Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserModel>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount account = await _googleSignIn.signIn();
      if (account == null) return Left(GoogleAuthCanceled());

      final GoogleSignInAuthentication googleAuth = await account.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.accessToken,
        accessToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      return Right(await userCredential.user.toDomain());
    } on FirebaseAuthException catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword(EmailAddress email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.value);
      return Right(unit);
    } on FirebaseException catch (e) {
      debugPrint("LoginDatasource resetPasswrod error ${e.code} | ${e.message}");
      return Left(ServerFailure());
    }
  }

}