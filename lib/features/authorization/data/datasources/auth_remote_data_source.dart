import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/core/models/user_model.dart';
import 'package:bando/core/utils/firebase_user_mapper.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthRemoteDataSource {
  Future<Either<Failure, UserModel>> registerWithEmailAndPassword(
    EmailAddress email,
    Password password,
    String username,
  );

  Future<UserModel> isLoggedIn();

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({@required FirebaseAuth firebaseAuth, @required GoogleSignIn googleSignIn})
      : assert(firebaseAuth != null),
        assert(googleSignIn != null),
        _firebaseAuth = firebaseAuth,
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
    } on FirebaseAuthException catch (e) {
      return (e.code == 'ERROR_EMAIL_ALREADY_IN_USE') ? Left(EmailAlreadyInUse()) : Left(ServerFailure());
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
