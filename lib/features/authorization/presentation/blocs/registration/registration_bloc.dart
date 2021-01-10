import 'dart:async';

import 'package:bando/core/entities/email_address.dart';
import 'package:bando/core/entities/password.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/authorization/domain/usecases/register_with_email_and_password_use_case.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'registration_event.dart';
part 'registration_state.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  RegisterWithEmailAndPasswordUseCase _registerUseCase;

  RegistrationBloc(this._registerUseCase) : super(RegistrationInitial());

  @override
  Stream<RegistrationState> mapEventToState(
    RegistrationEvent event,
  ) async* {
    if (event is RegisterWithEmailAndPasswordEvent) {
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
}
