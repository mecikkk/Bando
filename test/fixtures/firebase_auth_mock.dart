import 'dart:async';

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
  User get user => _isUserValid ? MockUser(isAnonymous: _isAnonymous) : MockNoClaimsUser(isAnonymous: _isAnonymous);
}

class MockUser extends Mock implements User {
  final bool _isAnonymous;

  MockUser({bool isAnonymous}) : _isAnonymous = isAnonymous;

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
        'claims': {'groupId': 'TestGroupId'},
      },
    );
  }
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
    return IdTokenResult({
      'claims': {'uid': 'TestUid'}
    });
  }
}
