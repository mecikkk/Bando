import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/core/utils/firebase_user_mapper.dart';
import 'package:bando/features/authorization/data/models/user_model.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as FireAuth;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthRemoteDataSource {
  Future<Either<Failure, UserModel>> signInWithEmailAndPassword(EmailAddress email, Password password);

  Future<Either<Failure, UserModel>> signInWithGoogle();

  Future<Either<Failure, UserModel>> registerWithEmailAndPassword(
      EmailAddress email, Password password, String username);

  Future<UserModel> isLoggedIn();

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FireAuth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({@required FireAuth.FirebaseAuth firebaseAuth, @required GoogleSignIn googleSignIn})
      : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  @override
  Future<Either<Failure, UserModel>> registerWithEmailAndPassword(
      EmailAddress email, Password password, String username) async {
    try {
      final userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(email: email.value, password: password.value);

      await userCredential.user.updateProfile(displayName: username);

      final user = await userCredential.user.toDomain();
      return Right(user);
    } on FireAuth.FirebaseAuthException catch (e) {
      return (e.code == 'ERROR_EMAIL_ALREADY_IN_USE') ? Left(EmailAlreadyInUse()) : Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserModel>> signInWithEmailAndPassword(EmailAddress email, Password password) async {
    try {
      final userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(email: email.value, password: password.value);

      final user = await userCredential.user.toDomain();
      return Right(user);
    } on FireAuth.FirebaseAuthException catch (e) {
      return (e.code == 'ERROR_WRONG_PASSWORD' || e.code == 'ERROR_USER_NOT_FOUND')
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

      final FireAuth.AuthCredential credential = FireAuth.GoogleAuthProvider.credential(
        idToken: googleAuth.accessToken,
        accessToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      return Right(await userCredential.user.toDomain());
    } on FireAuth.FirebaseAuthException catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<UserModel> isLoggedIn() async {
    final fUser = _firebaseAuth.currentUser;
    return (fUser != null) ? await fUser.toDomain() : null;
  }

  @override
  Future<void> logout() async {
    final fUser = _firebaseAuth.currentUser;
    (fUser.providerData[1].providerId == 'google.com') ? await _googleSignIn.signOut() : await _firebaseAuth.signOut();

    return;
  }
}
