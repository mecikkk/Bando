import 'dart:async';

import 'package:bando/auth/models/user_model.dart';
import 'file:///D:/Android/Bando/FlutterProject/bando/lib/repositories/auth_repository.dart';
import 'file:///D:/Android/Bando/FlutterProject/bando/lib/repositories/firestore_user_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository _authRepository;
  final FirestoreUserRepository _userRepository;

  RegisterBloc({
    @required FirestoreUserRepository userRepository,
    @required AuthRepository authRepository,
  })  : assert(userRepository != null),
        _userRepository = userRepository,
        assert(authRepository != null),
        _authRepository = authRepository,
        super(RegisterInitialState());

  @override
  Stream<RegisterState> mapEventToState(
    RegisterEvent event,
  ) async* {
    if (event is RegisterSubmittedEvent) {
      yield* _mapRegisterSubmittedEventToState(event.email, event.password, event.username);
    }
  }

  Stream<RegisterState> _mapRegisterSubmittedEventToState(String email, String password, String username) async* {
    yield RegisterSubmittingState();

    try {
      await _authRepository.signUp(email: email, password: password);

      User user = User(await _authRepository.getLoggedInUserId(), username: username);

      _userRepository.addNewUser(user);

      yield RegisterRegistrationSuccessState(user: user);
    } catch (_) {
      yield RegisterFailureState();
    }
  }

}
