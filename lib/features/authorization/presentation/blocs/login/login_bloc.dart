import 'dart:async';

import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/authorization/domain/usecases/reset_password_use_case.dart';
import 'package:bando/features/authorization/domain/usecases/sign_in_with_email_and_password_use_case.dart';
import 'package:bando/features/authorization/domain/usecases/sign_in_with_google_use_case.dart';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:bando/core/utils/utils.dart';
import 'package:bando/core/utils/constants.dart';

part 'login_event.dart';

part 'login_state.dart';

typedef Future<Either<Failure, User>> _SignInMethod();

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final SignInWithEmailAndPasswordUseCase _signInWithEmailAndPassword;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final ResetPasswordUseCase _resetPasswordUseCase;
  bool emailValid = true;
  bool passwordValid = false;

  LoginBloc(this._signInWithEmailAndPassword, this._signInWithGoogle, this._resetPasswordUseCase)
      : super(LoginInitial());

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is SignInWithEmailAndPasswordEvent) {
      if (emailValid && passwordValid) {
        final email = EmailAddress(value: event.email);
        final password = Password(value: event.password);
        yield* _signIn(() => _signInWithEmailAndPassword.call(email: email, password: password));
      } else
        yield Error(message: Texts.ENTERED_INCORRECT_DATA);
    }

    if (event is SignInWithGoogleEvent) {
      yield* _signIn(() => _signInWithGoogle.call());
    }

    if (event is EmailTextFieldChanged) {
      yield* _mapEmailTextFieldChangedEventToState(event.enteredText);
    }
    if (event is PasswordTextFieldChanged) {
      yield* _mapPasswordTextFieldChangedEventToState(event.enteredText);
    }
    if(event is ResetPasswordEvent) {
      yield* _mapResetPasswordEventToState(event.email);
    }
  }

  Stream<LoginState> _signIn(_SignInMethod signInMethod) async* {
    yield LoginLoadingState();

    final signInEither = await signInMethod();

    yield* signInEither.fold(
      (failure) async* {
        if (failure is UnconfiguredGroup)
          yield NotConfiguredGroupState(user: failure.user);
        else if (failure is WrongEmailOrPassword)
          yield Error(message: 'wrong_email_password');
        else if (failure is GoogleAuthCanceled)
          yield Error(message: 'google_auth_canceled');
        else
          yield Error(message: (failure.message != '') ? failure.message : Texts.SIGNING_IN_ERROR);
      },
      (user) async* {
        yield LoggingInSuccessState(user: user);
      },
    );
  }

  Stream<LoginState> _mapEmailTextFieldChangedEventToState(String enteredText) async* {
    var email = isEmailValid(enteredText);
    var result = email.fold(
      (failure) {
        emailValid = false;
        return failure.message;
      },
      (correct) {
        emailValid = true;
        return null;
      },
    );
    yield EmailFieldChangedState(result);
  }

  Stream<LoginState> _mapPasswordTextFieldChangedEventToState(String enteredText) async* {
    var password = isPasswordValid(enteredText);
    var result = password.fold(
      (failure) {
        passwordValid = false;
        return failure.message;
      },
      (correct) {
        passwordValid = true;
        return null;
      },
    );
    yield PasswordFieldChangedState(result);
  }

  Stream<LoginState> _mapResetPasswordEventToState(String email) async* {
    final EmailAddress emailAddress = EmailAddress(value: email);
    final result = await _resetPasswordUseCase.call(emailAddress);

    yield* result.fold(
      (failure) async* {
        yield Error(message : failure.message);
      },
      (success) async* {
        ResetPasswordSuccessState();
      },
    );
  }
}
