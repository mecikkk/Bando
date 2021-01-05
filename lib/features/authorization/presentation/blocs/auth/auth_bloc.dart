import 'dart:async';

import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/authorization/domain/usecases/check_is_logged_in_use_case.dart';
import 'package:bando/features/authorization/domain/usecases/logout_use_case.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'auth_event.dart';
part 'auth_state.dart';

const String AUTH_SERVER_ERROR = 'Server failure';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckIsLoggedInUseCase _checkIsLoggedIn;
  final LogoutUseCase _logout;

  AuthBloc(this._checkIsLoggedIn, this._logout)
      : super(AuthInitial());

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    if (event is AuthStart) {
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
      final logoutEither = await _logout.call();

      try {
        yield* logoutEither.fold(
          (failure) async* {
            yield Error(message: AUTH_SERVER_ERROR);
          },
          (unit) async* {
            yield UnauthorizedState();
          },
        );
      } on Exception {
        yield Error(message: AUTH_SERVER_ERROR);
      }
    }
  }

}
