import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/errors/exceptions.dart';
import 'package:bando/core/models/user_model.dart';
import 'package:bando/features/login_register/data/datasources/remote_data_source.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../fixtures/firebase_auth_mock.dart';
import '../../../fixtures/google_sign_mock.dart';

class MockFirebaseAuth2 extends Mock implements FirebaseAuth {}

void main() {
  RemoteDataSourceImpl dataSource;
  MockFirebaseAuth auth;
  EmailAddress email;
  Password password;
  UserModel user;
  MockGoogleSignIn googleSignIn;
  MockFirebaseAuth2 firebaseAuth2;

  setUp(() {
    auth = MockFirebaseAuth();
    password = Password(password: 'pass123');
    email = EmailAddress(email: 'test@email.com');
    user = UserModel(uid: 'TestUid', displayName: 'TestName', groupId: 'TestGroupId');
    googleSignIn = MockGoogleSignIn();
    firebaseAuth2 = MockFirebaseAuth2();
    dataSource = RemoteDataSourceImpl(firebaseAuth: firebaseAuth2, googleSignIn: googleSignIn);
  });

  group('RemoteDataSource tests - ', () {
    test('should return UserModel created from Firebase User', () async {
      final dataSource = RemoteDataSourceImpl(firebaseAuth: auth, googleSignIn: googleSignIn);

      final resultUser = await dataSource.signInWithEmailAndPassword(email, password);
      expect(resultUser, user);
    });

    test('should throw UserClaimsException when user sign in', () async {
      when(firebaseAuth2.signInWithEmailAndPassword(email: email.email, password: password.password))
          .thenAnswer((_) => Future.value(MockUserCredential(isUserValid: false)));

      expect(() async => await dataSource.signInWithEmailAndPassword(email, password),
          throwsA(isInstanceOf<UserClaimsException>()));
    });

    test('should return UserModel from new account', () async {
      when(firebaseAuth2.createUserWithEmailAndPassword(email: email.email, password: password.password))
          .thenAnswer((_) => Future.value(MockUserCredential(isUserValid: true)));

      final createdUser = await dataSource.registerWithEmailAndPassword(email, password, 'TestName');

      expect(createdUser, equals(user));
    });

    test('should throw UserClaimsException when user create a new account', () async {
      when(firebaseAuth2.createUserWithEmailAndPassword(email: email.email, password: password.password))
          .thenAnswer((_) => Future.value(MockUserCredential(isUserValid: false)));

      expect(() async => await dataSource.registerWithEmailAndPassword(email, password, 'TestName'),
          throwsA(isInstanceOf<UserClaimsException>()));
    });

    test('should return UserModel from Google account', () async {
      when(firebaseAuth2.signInWithCredential(any))
          .thenAnswer((_) => Future.value(MockUserCredential(isUserValid: true)));

      final createdUser = await dataSource.signInWithGoogle();

      expect(createdUser, equals(user));
    });

    test('should throw UserClaimsException when user create a new account with Google', () async {
      when(firebaseAuth2.signInWithCredential(any))
          .thenAnswer((_) => Future.value(MockUserCredential(isUserValid: false)));

      final createdUser = dataSource.signInWithGoogle;

      expect(() async => await createdUser(), throwsA(isInstanceOf<UserClaimsException>()));
    });
  });
}
