import 'dart:async';

import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/authorization/domain/usecases/check_is_logged_in_use_case.dart';
import 'package:bando/features/authorization/domain/usecases/logout_use_case.dart';
import 'package:bando/features/authorization/domain/usecases/sign_in_with_email_and_password_use_case.dart';
import 'package:bando/features/authorization/domain/usecases/sign_in_with_google_use_case.dart';
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
  final CheckIsLoggedInUseCase _checkIsLoggedIn;
  final LogoutUseCase _logout;
  final SignInWithEmailAndPasswordUseCase _signInWithEmailAndPassword;
  final SignInWithGoogleUseCase _signInWithGoogle;

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
      yield SplashScreenState(
      );

      final logoutEither = await _logout.call(
      );

      try {
        yield* logoutEither.fold(
              (failure) async* {
            yield Error(
                message: AUTH_SERVER_ERROR);
          },
              (unit) async* {
            yield UnauthorizedState(
            );
          },
        );
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
          yield NotConfiguredGroupState(
              user: failure.user);
        else if (failure is WrongEmailOrPassword)
          yield WrongEmailOrPasswordState(
          );
        else if (failure is GoogleAuthCanceled)
          yield GoogleAuthCanceledState(
          );
        else
          yield Error(
              message: (failure.message != '') ? failure.message : SIGN_IN_ERROR);
      },
      (user) async* {
        yield AuthorizedState(user: user);
      },
    );
  }
}
