import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  final stateChangedStreamController = StreamController<User>();
  User _currentUser;

  MockFirebaseAuth({signedIn = false}) {
    if (signedIn) {
      signInWithCredential(null);
    }
  }

  @override
  User get currentUser {
    return _currentUser;
  }

  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) {
    return _fakeSignIn();
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    @required String email,
    @required String password,
  }) {
    return _fakeSignIn();
  }

  @override
  Future<UserCredential> signInWithCustomToken(String token) async {
    return _fakeSignIn();
  }

  @override
  Future<UserCredential> signInAnonymously() {
    return _fakeSignIn(isAnonymous: true);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    stateChangedStreamController.add(null);
  }

  Future<UserCredential> _fakeSignIn({bool isAnonymous = false}) {
    final userCredential = MockUserCredential(isAnonymous: isAnonymous);
    _currentUser = userCredential.user;
    stateChangedStreamController.add(_currentUser);
    return Future.value(userCredential);
  }

  @override
  Stream<User> get onAuthStateChanged => authStateChanges();

  @override
  Stream<User> authStateChanges() => stateChangedStreamController.stream;
}

class MockUserCredential extends Mock implements UserCredential {
  final bool _isAnonymous;
  final bool _isUserValid;

  MockUserCredential({bool isAnonymous, bool isUserValid = true})
      : _isAnonymous = isAnonymous,
        _isUserValid = isUserValid;

  @override
  User get user =>
      _isUserValid ? MockFirebaseUser(isAnonymous: _isAnonymous) : MockNoClaimsUser(isAnonymous: _isAnonymous);
}

class MockFirebaseUser extends Mock implements User {
  final bool _isAnonymous;

  MockFirebaseUser({bool isAnonymous}) : _isAnonymous = isAnonymous;

  @override
  String get displayName => 'TestName';

  @override
  String get uid => 'TestUid';

  @override
  String get email => 'test@email.com';

  @override
  bool get isAnonymous => _isAnonymous;

  @override
  List<UserInfo> get providerData =>
      [MockFirebaseUserInfo(
      ), MockFirebaseUserInfo(
      )
      ];

  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) async {
    return IdTokenResult(
      {
        'claims': {'groupId': 'TestGroupId'},
      },
    );
  }
}

class MockGoogleUser extends Mock implements User {
  final bool _isAnonymous;

  MockGoogleUser({bool isAnonymous}) : _isAnonymous = isAnonymous;

  @override
  String get displayName => 'TestName';

  @override
  String get uid => 'TestUid';

  @override
  String get email => 'test@email.com';

  @override
  bool get isAnonymous => _isAnonymous;

  @override
  List<UserInfo> get providerData =>
      [MockGoogleUserInfo(
      ), MockGoogleUserInfo(
      )
      ];

  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) async {
    return IdTokenResult(
      {
        'claims': {'groupId': 'TestGroupId'},
      },
    );
  }
}

class MockGoogleUserInfo extends Mock implements UserInfo {
  @override
  String get providerId => 'google.com';
}

class MockFirebaseUserInfo extends Mock implements UserInfo {
  @override
  String get providerId => 'password';
}

class MockNoClaimsUser extends Mock implements User {
  final bool _isAnonymous;

  MockNoClaimsUser({bool isAnonymous}) : _isAnonymous = isAnonymous;

  @override
  String get displayName => 'TestName';

  @override
  String get uid => 'TestUid';

  @override
  String get email => 'test@email.com';

  @override
  bool get isAnonymous => _isAnonymous;

  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) async {
    return IdTokenResult(
        {
          'claims': {'uid': 'TestUid'}
        });
  }
}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {
  final Map<String, dynamic> _data;

  MockDocumentSnapshot(this._data);

  @override
  Map<String, dynamic> data() {
    return _data;
  }
}
