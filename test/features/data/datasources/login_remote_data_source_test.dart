import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/authorization/data/datasources/login_remote_data_source.dart';
import 'package:bando/features/authorization/data/models/user_model.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';

import '../../../fixtures/firebase_auth_mock.dart';
import '../../../fixtures/google_sign_mock.dart';

class MockFirebaseAuth2 extends Mock implements FirebaseAuth {}

class MockCanceledGoogleSignIn extends Mock implements GoogleSignIn {}

void main() {

  LoginRemoteDataSource dataSource;
  MockFirebaseAuth auth;
  EmailAddress email;
  Password password;
  UserModel user;
  MockGoogleSignIn googleSignIn;
  MockCanceledGoogleSignIn canceledGoogleSignIn;
  MockFirebaseAuth2 firebaseAuth2;

  setUp(() {
    auth = MockFirebaseAuth();
    password = Password(value: 'pass123');
    email = EmailAddress(value: 'test@email.com');
    user = UserModel(uid: 'TestUid', displayName: 'TestName', groupId: 'TestGroupId');
    googleSignIn = MockGoogleSignIn();
    canceledGoogleSignIn = MockCanceledGoogleSignIn();
    firebaseAuth2 = MockFirebaseAuth2();
    dataSource = LoginRemoteDataSourceImpl(firebaseAuth: firebaseAuth2, googleSignIn: googleSignIn);
  });

  group('LoginRemoteDataSource tests - ', () {
    test('should return UserModel from Firebase User', () async {
      final dataSource = LoginRemoteDataSourceImpl(firebaseAuth: auth, googleSignIn: googleSignIn);

      final resultUser = await dataSource.signInWithEmailAndPassword(email, password);
      expect(resultUser, Right(user));
    });

    test('should return WrongEmailOrPassword when user tries to sign in with wrong password', () async {
      when(firebaseAuth2.signInWithEmailAndPassword(email: email.value, password: password.value))
          .thenThrow(FirebaseAuthException(message: 'Wrong password', code: 'ERROR_WRONG_PASSWORD'));

      final resultUser = await dataSource.signInWithEmailAndPassword(email, password);

      expect(resultUser, Left(WrongEmailOrPassword()));
    });

    test('should return UserModel from Google account', () async {
      when(firebaseAuth2.signInWithCredential(any))
          .thenAnswer((_) => Future.value(MockUserCredential(isUserValid: true)));

      final createdUser = await dataSource.signInWithGoogle();

      expect(createdUser, equals(Right(user)));
    });

    test('should return GoogleAuthCanceled when user resigns from logging in', () async {
      final dataSource = LoginRemoteDataSourceImpl(firebaseAuth: auth, googleSignIn: canceledGoogleSignIn);

      when(firebaseAuth2.signInWithCredential(any))
          .thenAnswer((_) => Future.value(MockUserCredential(isUserValid: true)));

      final createdUser = await dataSource.signInWithGoogle();

      expect(createdUser, equals(Left(GoogleAuthCanceled())));
    });
  });
}