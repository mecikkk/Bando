import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as FireAuth;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class RemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword(EmailAddress email, Password password);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> registerWithEmailAndPassword(EmailAddress email, Password password, String username);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final FireAuth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  RemoteDataSourceImpl({@required FireAuth.FirebaseAuth firebaseAuth, @required GoogleSignIn googleSignIn})
      : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  @override
  Future<UserModel> registerWithEmailAndPassword(EmailAddress email, Password password, String username) async {
    final userCredential =
        await _firebaseAuth.createUserWithEmailAndPassword(email: email.email, password: password.password);

    await userCredential.user.updateProfile(displayName: username);

    return await UserModel.fromFirebase(userCredential.user);
  }

  @override
  Future<UserModel> signInWithEmailAndPassword(EmailAddress email, Password password) async {
    final userCredential =
        await _firebaseAuth.signInWithEmailAndPassword(email: email.email, password: password.password);

    return await UserModel.fromFirebase(userCredential.user);
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    final GoogleSignInAccount account = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await account.authentication;

    final FireAuth.AuthCredential credential = FireAuth.GoogleAuthProvider.credential(
      idToken: googleAuth.accessToken,
      accessToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    return await UserModel.fromFirebase(userCredential.user);
  }
}
