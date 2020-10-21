import 'dart:async';

import 'package:bando/models/group_model.dart';
import 'package:bando/models/user_model.dart';
import 'package:bando/repositories/auth_repository.dart';
import 'package:bando/repositories/firestore_group_repository.dart';
import 'package:bando/repositories/firestore_user_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirestoreUserRepository _userRepository;
  final FirestoreGroupRepository _groupRepository;
  final AuthRepository _authRepository;

  ProfileBloc({
    @required FirestoreUserRepository userRepository,
    @required FirestoreGroupRepository groupRepository,
    @required AuthRepository authRepository,
  })  : assert(userRepository != null),
        _userRepository = userRepository,
        assert(groupRepository != null),
        _groupRepository = groupRepository,
        assert(authRepository != null),
        _authRepository = authRepository,
        super(ProfileInitial());

  @override
  Stream<ProfileState> mapEventToState(
    ProfileEvent event,
  ) async* {
      if(event is ProfileInitialEvent) {
        yield* _mapProfileInitialEventToState();
      } else if(event is ProfileLoadAllDataEvent) {
        yield* _mapProfileInitialEventToState();
      } else if (event is ProfileLogoutEvent) {
        yield* _mapProfileLogoutEventToState();
      } else if (event is ProfileChangeLeaderEvent) {
        yield* _mapProfileChangeLeaderEventToState(event.newLeaderId);
      } else if (event is ProfileChangeUsernameEvent) {
        yield* _mapProfileChangeUsernameEventToState(event.newUsername);
      } else if (event is ProfileChangePasswordEvent) {
        yield* _mapProfileChangePasswordEventToState(event.password);
      }

  }


  Stream<ProfileState> _mapProfileInitialEventToState() async* {
    yield ProfileLoadingState();

    try {

      User user = await _userRepository.currentUser();
      Group group = await _groupRepository.getGroup(user.groupId);

      yield ProfileDataLoadedState(user: user, group: group);
      yield ProfileSuccessState();

    } catch (e) {
      debugPrint("-- ProfileBloc | Initial error : $e");
      yield ProfileFailureState();
    }
  }

  Stream<ProfileState> _mapProfileLogoutEventToState() async* {
    yield ProfileLoadingState();

    try {

      await _authRepository.signOut();

      yield ProfileLogoutSuccessState();

    } catch (e) {
      debugPrint("-- ProfileBloc | LogoutEvent error : $e");
      yield ProfileFailureState();
    }
  }

  Stream<ProfileState> _mapProfileChangeLeaderEventToState(String newLeaderId) async* {

    try {
      await _groupRepository.setLeader(newLeaderId);

      yield ProfileLeaderChangedSuccessfullyState();
    } catch(e) {
      debugPrint("-- ProfileBloc | ChangeLeaderEventToState error : $e");
      yield ProfileFailureState();
    }

  }

  Stream<ProfileState> _mapProfileChangeUsernameEventToState(String newUsername) async* {
    try {
      await _groupRepository.changeMemberUsername(newUsername);
      await _userRepository.changeUsername(newUsername);

      yield ProfileUserDataUpdateSuccessState();
    } catch(e) {
      debugPrint("-- ProfileBloc | ChageUsernameEventToState error : $e");
      yield ProfileFailureState();
    }
  }

  Stream<ProfileState> _mapProfileChangePasswordEventToState(String password) async* {
    try {
      await _authRepository.changePassword(password);
      yield ProfileUserDataUpdateSuccessState();
    } catch (e) {
      debugPrint("-- ProfileBloc | ChagePasswordEventToState error : $e");
      yield ProfileFailureState();
    }
  }
}
