import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/authorization/data/datasources/auth_remote_data_source.dart';
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
  AuthRemoteDataSourceImpl dataSource;
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
    dataSource = AuthRemoteDataSourceImpl(firebaseAuth: firebaseAuth2, googleSignIn: googleSignIn);
  });

  group('RemoteDataSource tests - ', () {


    test('should return UserModel from new account', () async {
      when(firebaseAuth2.createUserWithEmailAndPassword(email: email.value, password: password.value))
          .thenAnswer((_) => Future.value(MockUserCredential(isUserValid: true)));

      final createdUser = await dataSource.registerWithEmailAndPassword(email, password, 'TestName');

      expect(createdUser, equals(Right(user)));
    });

    test('should return EmailAlreadyInUse when user tries to create account on exist user email', () async {
      when(firebaseAuth2.createUserWithEmailAndPassword(email: email.value, password: password.value))
          .thenThrow(FirebaseAuthException(message: 'Email in use', code: 'ERROR_EMAIL_ALREADY_IN_USE'));

      final resultUser = await dataSource.registerWithEmailAndPassword(email, password, 'SomeName');

      expect(resultUser, Left(EmailAlreadyInUse()));
    });

    test('should return UserModel when checks is logged in', () async {
      //arrange
      when(firebaseAuth2.currentUser).thenReturn(MockFirebaseUser());

      //act
      final userModel = await dataSource.isLoggedIn();

      //assert
      expect(userModel, equals(user));
    });

    test('should return null when checks is logged in', () async {
      //arrange
      when(firebaseAuth2.currentUser).thenReturn(null);

      //act
      final userModel = await dataSource.isLoggedIn();

      //assert
      expect(userModel, null);
    });

    test('should invoke sign out method from google sign in', () async {
      when(firebaseAuth2.currentUser).thenReturn(MockGoogleUser());

      await dataSource.logout();

      verifyNever(firebaseAuth2.signOut());
    });

    test('should invoke sign out method from firebase auth', () async {
      when(firebaseAuth2.currentUser).thenReturn(MockFirebaseUser());

      await dataSource.logout();

      verify(firebaseAuth2.signOut());
    });
  });
}
