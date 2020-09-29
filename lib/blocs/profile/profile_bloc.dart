import 'dart:async';

import 'package:bando/models/group_model.dart';
import 'package:bando/models/user_model.dart';
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

  ProfileBloc({
    @required FirestoreUserRepository userRepository,
    @required FirestoreGroupRepository groupRepository,
  })  : assert(userRepository != null),
        _userRepository = userRepository,
        assert(groupRepository != null),
        _groupRepository = groupRepository,
        super(ProfileInitial());

  @override
  Stream<ProfileState> mapEventToState(
    ProfileEvent event,
  ) async* {
      if(event is ProfileInitialEvent) {
        yield* _mapProfileInitialEventToState();
      }
      if(event is ProfileLoadAllDataEvent) {
        yield* _mapProfileInitialEventToState();
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
}
