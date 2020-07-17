import 'dart:async';

import 'package:bando/auth/models/group_model.dart';
import 'package:bando/auth/models/user_model.dart';
import 'package:bando/auth/repository/firestore_group_repository.dart';
import 'package:bando/auth/repository/firestore_user_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FirestoreUserRepository _userRepository;
  final FirestoreGroupRepository _groupRepository;

  HomeBloc({
    @required FirestoreUserRepository userRepository,
    @required FirestoreGroupRepository groupRepository,
  })  : assert(userRepository != null),
        _userRepository = userRepository,
        assert(groupRepository != null),
        _groupRepository = groupRepository,
        super(HomeInitialState());

  @override
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {
    if(event is HomeInitialEvent) {
      yield* _mapHomeInitialEventToState(event.uid);
    }
  }

  Stream<HomeState> _mapHomeInitialEventToState(String uid) async* {
    yield HomeLoadingState();

    try {
      User user = await _userRepository.getUser(uid);

      if(user.groupId != "") {
        Group group = await _groupRepository.getGroup(user.groupId);
        yield HomeReadyState(group: group, user: user);
      } else {
        yield HomeNoGroupState(user: user);
      }

    } catch (_) {
      yield HomeFailureState();
    }
  }
}
