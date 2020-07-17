import 'dart:async';

import 'package:bando/auth/models/group_model.dart';
import 'package:bando/auth/models/user_model.dart';
import 'package:bando/auth/repository/auth_repository.dart';
import 'package:bando/auth/repository/firestore_group_repository.dart';
import 'package:bando/auth/repository/firestore_user_repository.dart';
import 'package:bando/utils/validator.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'register_event.dart';

part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository _authRepository;
  final FirestoreUserRepository _userRepository;
  final FirestoreGroupRepository _groupRepository;

  RegisterBloc({
    @required FirestoreUserRepository userRepository,
    @required AuthRepository authRepository,
    @required FirestoreGroupRepository groupRepository,
  })  : assert(userRepository != null),
        _userRepository = userRepository,
        assert(authRepository != null),
        _authRepository = authRepository,
        assert(groupRepository != null),
        _groupRepository = groupRepository,
        super(RegisterState.initial());

  @override
  Stream<RegisterState> mapEventToState(
    RegisterEvent event,
  ) async* {
    if (event is RegisterEmailChanged) {
      yield* _mapRegisterEmailChangedToState(event.email);
    } else if (event is RegisterPasswordChanged) {
      yield* _mapRegisterPasswordChangedToState(event.password);
    } else if(event is RegisterUsernameChanged) {
      yield* _mapRegisterUsernameChangedToState(event.username);
    } else if(event is RegisterGroupNameChanged) {
      yield* _mapRegisterGroupNameChangedToState(event.groupName);
    } else if (event is RegisterSubmittedEvent) {
      yield* _mapRegisterSubmittedEventToState(event.email, event.password, event.username);
    } else if (event is RegisterJoiningToGroup) {
      yield* _mapRegisterJoiningToExistingGroupToState();
    } else if (event is RegisterNewGroupCreating) {
      yield* _mapRegisterNewGroupCreatingToState();
    } else if (event is RegisterSubmittedNewGroup) {
      yield* _mapRegisterSubmittedWithNewGroupEvent(event.groupName);
    } else if (event is RegisterSubmittedJoinToGroup) {
      yield* _mapRegisterSubmittedAndJoinedToGroupEvent(event.groupId);
    } else if (event is RegisterQRCodeScanned) {
      yield* _mapRegisterQRCodeScannedToEvent(event.groupId);
    }
  }

  Stream<RegisterState> _mapRegisterEmailChangedToState(String email) async* {
    yield state.update(
      isEmailValid: Validators.isValidEmail(email),
    );
  }

  Stream<RegisterState> _mapRegisterPasswordChangedToState(String password) async* {
    yield state.update(
      isPasswordValid: Validators.isValidPassword(password),
    );
  }

  Stream<RegisterState> _mapRegisterUsernameChangedToState(String username) async* {
    yield state.update(
      isUsernameValid: Validators.isValidUsername(username)
    );
  }

  Stream<RegisterState> _mapRegisterGroupNameChangedToState(String groupName) async* {
    yield state.update(
        isGroupNameValid: Validators.isValidUsername(groupName)
    );
  }

  Stream<RegisterState> _mapRegisterSubmittedEventToState(String email, String password, String username) async* {
    yield RegisterState.registrationSubmitting();

    try {
      await _authRepository.signUp(email: email, password: password);

      User user = User(await _authRepository.getLoggedInUserId(), username: username);

      _userRepository.addNewUser(user);

      yield RegisterState.registered();
    } catch (_) {
      yield RegisterState.failure();
    }
  }

  Stream<RegisterState> _mapRegisterNewGroupCreatingToState() async* {
    yield RegisterState.newGroupCreating();
  }

  Stream<RegisterState> _mapRegisterJoiningToExistingGroupToState() async* {
    yield RegisterState.joiningToExistingGroup();
  }

  Stream<RegisterState> _mapRegisterSubmittedWithNewGroupEvent(String groupName) async* {
    yield RegisterState.newGroupSubmitting();

    try {
      String uid = await _authRepository.getLoggedInUserId();

      String groupId = await _groupRepository.createNewGroup(Group("", name: groupName, members: [uid]));

      await _userRepository.addGroupToUser(uid, groupId);

      // TODO : Create directory in Storage for group.

      yield RegisterState.newGroupConfigured(groupId);
    } catch (_) {
      yield RegisterState.failure();
    }
  }

  Stream<RegisterState> _mapRegisterSubmittedAndJoinedToGroupEvent(String groupId) async* {
    yield RegisterState.joinToGroupSubmitting();

    try {
      String uid = await _authRepository.getLoggedInUserId();

      await _userRepository.addGroupToUser(uid, groupId);
      await _groupRepository.addUserToGroup(groupId, uid);

      // TODO : Download group lyrics folder if exist

      yield RegisterState.joiningToGroupConfigured();
    } catch (_) {
      yield RegisterState.failure();
    }
  }

  Stream<RegisterState> _mapRegisterQRCodeScannedToEvent(String groupId) async* {
    yield RegisterState.searchingForGroup();

    try {

      Group group = await _groupRepository.getGroup(groupId);

      yield RegisterState.groupFoundByQRCode(group.name);
    } catch (_) {
      yield RegisterState.failureFindingGroupByQRCode();
    }

  }
}
