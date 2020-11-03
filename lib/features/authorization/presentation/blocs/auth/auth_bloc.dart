import 'dart:async';

import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/authorization/domain/usecases/check_is_logged_in.dart';
import 'package:bando/features/authorization/domain/usecases/logout.dart';
import 'package:bando/features/authorization/domain/usecases/sign_in_with_email_and_password.dart';
import 'package:bando/features/authorization/domain/usecases/sign_in_with_google.dart';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'auth_event.dart';
part 'auth_state.dart';

const String AUTH_SERVER_ERROR = 'Server failure';
const String SIGN_IN_ERROR = 'Signing in error';

typedef Future<Either<Failure, User>> _SignInMethod();

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckIsLoggedIn _checkIsLoggedIn;
  final Logout _logout;
  final SignInWithEmailAndPassword _signInWithEmailAndPassword;
  final SignInWithGoogle _signInWithGoogle;

  AuthBloc(this._checkIsLoggedIn, this._logout, this._signInWithEmailAndPassword, this._signInWithGoogle)
      : super(AuthInitial());

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    if (event is AuthInitial) {
      yield SplashScreenState();

      final authEither = await _checkIsLoggedIn.call();

      yield* authEither.fold(
        (failure) async* {
          if (failure is ServerFailure)
            yield Error(message: AUTH_SERVER_ERROR);
          else
            yield UnauthorizedState();
        },
        (user) async* {
          yield AuthorizedState(user: user);
        },
      );
    }

    if (event is LogoutEvent) {
      yield SplashScreenState();

      try {
        await _logout.call();
        yield UnauthorizedState();
      } on Exception {
        yield Error(message: AUTH_SERVER_ERROR);
      }
    }

    if (event is SignInWithEmailAndPasswordEvent) {
      yield* _signIn(() => _signInWithEmailAndPassword.call(email: event.email, password: event.password));
    }

    if (event is SignInWithGoogleEvent) {
      yield* _signIn(() => _signInWithGoogle.call());
    }
  }

  Stream<AuthState> _signIn(_SignInMethod signInMethod) async* {
    yield LoadingState();

    final signInEither = await signInMethod();

    yield* signInEither.fold(
      (failure) async* {
        if (failure is UnconfiguredGroup)
          yield UnconfiguredGroupState(user: failure.user);
        else
          yield Error(message: (failure.message != '') ? failure.message : SIGN_IN_ERROR);
      },
      (user) async* {
        yield AuthorizedState(user: user);
      },
    );
  }
}
