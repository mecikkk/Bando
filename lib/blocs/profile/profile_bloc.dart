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

      yield ProfileLogoutSuccesState();

    } catch (e) {
      debugPrint("-- ProfileBloc | LogoutEvent error : $e");
      yield ProfileFailureState();
    }

  }
}
