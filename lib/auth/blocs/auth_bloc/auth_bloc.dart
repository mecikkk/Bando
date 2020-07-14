import 'dart:async';

import 'package:bando/auth/repository/auth_repository.dart';
import 'package:bando/auth/repository/firestore_user_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({@required AuthRepository authRepository}) :
        _authRepository = authRepository, super(AuthInitial());


  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    if(event is AuthStarted) {
      yield* _mapAuthStartedToState();
    } else if (event is AuthLoggedIn) {
      yield* _mapAuthLoggedInToState();
    } else if(event is AuthLoggedOut) {
      yield* _mapAuthLoggedOutToState();
    }
  }

  Stream<AuthState> _mapAuthStartedToState() async* {
    print("Checking is signed in");
    final isSignedIn = await _authRepository.isSignedIn();
    print("After checking");

    if(isSignedIn) {
      yield Authenticated(await _authRepository.getLoggedInUserId());
    } else {
      yield Unauthenticated();
    }
  }

  Stream<AuthState> _mapAuthLoggedInToState() async* {
    yield Authenticated(await _authRepository.getLoggedInUserId());
  }

  Stream<AuthState> _mapAuthLoggedOutToState() async* {
    yield Unauthenticated();
    _authRepository.signOut();
  }

}
