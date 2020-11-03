import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/features/authorization/data/models/user_model.dart';
import 'package:bando/features/authorization/data/datasources/auth_remote_data_source.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../fixtures/firebase_auth_mock.dart';
import '../../../fixtures/google_sign_mock.dart';

class MockFirebaseAuth2 extends Mock implements FirebaseAuth {}

void main() {
  AuthRemoteDataSourceImpl dataSource;
  MockFirebaseAuth auth;
  EmailAddress email;
  Password password;
  UserModel user;
  MockGoogleSignIn googleSignIn;
  MockFirebaseAuth2 firebaseAuth2;

  setUp(() {
    auth = MockFirebaseAuth();
    password = Password(value: 'pass123');
    email = EmailAddress(value: 'test@email.com');
    user = UserModel(uid: 'TestUid', displayName: 'TestName', groupId: 'TestGroupId');
    googleSignIn = MockGoogleSignIn();
    firebaseAuth2 = MockFirebaseAuth2();
    dataSource = AuthRemoteDataSourceImpl(firebaseAuth: firebaseAuth2, googleSignIn: googleSignIn);
  });

  group('RemoteDataSource tests - ', () {
    test('should return UserModel from Firebase User', () async {
      final dataSource = AuthRemoteDataSourceImpl(firebaseAuth: auth, googleSignIn: googleSignIn);

      final resultUser = await dataSource.signInWithEmailAndPassword(email, password);
      expect(resultUser, user);
    });

    test('should return UserModel from new account', () async {
      when(firebaseAuth2.createUserWithEmailAndPassword(email: email.value, password: password.value))
          .thenAnswer((_) => Future.value(MockUserCredential(isUserValid: true)));

      final createdUser = await dataSource.registerWithEmailAndPassword(email, password, 'TestName');

      expect(createdUser, equals(user));
    });

    test('should return UserModel from Google account', () async {
      when(firebaseAuth2.signInWithCredential(any))
          .thenAnswer((_) => Future.value(MockUserCredential(isUserValid: true)));

      final createdUser = await dataSource.signInWithGoogle();

      expect(createdUser, equals(user));
    });
  });
}
