import 'dart:async';

import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/core/utils/constants.dart';
import 'package:bando/core/utils/utils.dart';
import 'package:bando/features/authorization/domain/usecases/register_with_email_and_password_use_case.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'registration_event.dart';
part 'registration_state.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  RegisterWithEmailAndPasswordUseCase _registerUseCase;
  bool emailValid = false;
  bool passwordValid = false;
  bool usernameValid = false;

  RegistrationBloc(this._registerUseCase) : super(RegistrationInitial());

  @override
  Stream<RegistrationState> mapEventToState(
    RegistrationEvent event,
  ) async* {
    if (event is RegisterWithEmailAndPasswordEvent) {
      yield* _mapRegisterWithEmailAndPasswordEventToState(event);
    } else if (event is ValidateRegistrationEmailEvent) {
      yield* _mapValidateRegistrationEmailEventToState(event.enteredText);
    } else if (event is ValidateRegistrationPasswordEvent) {
      yield* _mapValidateRegistrationPasswordEventToState(event.enteredText);
    } else if (event is ValidateRegistrationUsernameEvent) {
      yield* _mapValidateRegistrationUsernameEventToState(event.enteredText);
    }
  }

  Stream<RegistrationState> _mapRegisterWithEmailAndPasswordEventToState(
      RegisterWithEmailAndPasswordEvent event) async* {
    if (!usernameValid && !emailValid && !passwordValid) {
      yield RegistrationFailureState(failure: EnteredDataFailure());
    } else {
      yield RegistrationLoadingState();
      try {
        final email = EmailAddress(value: event.email);
        final password = Password(value: event.password);

        final registrationResult = await _registerUseCase.call(email, password, event.username);

        yield* registrationResult.fold(
          (failure) async* {
            yield RegistrationFailureState(failure: failure);
          },
          (user) async* {
            yield RegistrationSuccess(user: user);
          },
        );
      } on Exception {
        yield RegistrationFailureState(failure: ServerFailure());
      }
    }
  }

  Stream<RegistrationState> _mapValidateRegistrationUsernameEventToState(String enteredText) async* {
    String message;

    if (enteredText.isEmpty) {
      message = Texts.FIELD_REQUIRED;
      usernameValid = false;
    } else {
      message = null;
      usernameValid = true;
    }

    yield UsernameVerifiedState(message: message);
  }

  Stream<RegistrationState> _mapValidateRegistrationEmailEventToState(String enteredText) async* {
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
    yield EmailVerifiedState(message: result);
  }

  Stream<RegistrationState> _mapValidateRegistrationPasswordEventToState(String enteredText) async* {
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
    yield PasswordVerifiedState(message: result);
  }
}
