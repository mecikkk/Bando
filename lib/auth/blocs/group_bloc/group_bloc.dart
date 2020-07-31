import 'dart:async';

import 'package:bando/auth/models/group_model.dart';
import 'package:bando/auth/models/user_model.dart';
import 'file:///D:/Android/Bando/FlutterProject/bando/lib/repositories/firestore_group_repository.dart';
import 'file:///D:/Android/Bando/FlutterProject/bando/lib/repositories/firestore_user_repository.dart';
import 'package:bando/utils/util.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'group_event.dart';

part 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final FirestoreUserRepository _userRepository;
  final FirestoreGroupRepository _groupRepository;

  GroupBloc({
    @required FirestoreGroupRepository groupRepository,
    @required FirestoreUserRepository userRepository,
  })  : assert(userRepository != null),
        _userRepository = userRepository,
        assert(groupRepository != null),
        _groupRepository = groupRepository,
        super(GroupInitialState(configurationType: GroupConfigurationType.CREATING_GROUP));

  @override
  Stream<GroupState> mapEventToState(
    GroupEvent event,
  ) async* {
    if (event is GroupConfigurationTypeChangeEvent) {
      yield* _mapConfigurationChangeEventToState(event.configurationType);
    } else if (event is GroupQRCodeScannedEvent) {
      yield* _mapGroupQRCodeScannedEventToState(event.groupId);
    } else if (event is GroupConfigurationSubmittingEvent) {
      yield* _mapGroupConfigurationSubmittingEventToState(event.configurationType, event.uid, event.groupId, event.groupName);
    }
  }

  Stream<GroupState> _mapConfigurationChangeEventToState(GroupConfigurationType configurationType) async* {
    yield GroupInitialState(configurationType: configurationType);
  }

  Stream<GroupState> _mapGroupQRCodeScannedEventToState(String groupId) async* {
    yield GroupByQRCodeLoadingState();

    try {
      Group group = await _groupRepository.getGroup(groupId);
      yield GroupByQRCodeFoundState(group: group);
    } catch (_) {
      yield GroupByQRCodeNotFoundState();
    }
  }

  Stream<GroupState> _mapGroupConfigurationSubmittingEventToState(
    GroupConfigurationType configurationType,
    String uid,
    String groupId,
    String groupName,
  ) async* {

    yield GroupLoadingState(loadingType: configurationType);
    Group group;

    try {
      User user = await _userRepository.getUser(uid);

      if(configurationType == GroupConfigurationType.JOINING_TO_GROUP) {
        await _userRepository.addGroupToUser(uid, groupId);
        group = await _groupRepository.addUserToGroup(groupId, user);
      } else {

        Group newGroup = Group("", name: groupName, members: [user.toEntity().toMap()]);
        String newGroupId = await _groupRepository.createNewGroup(newGroup);
        group = newGroup.copyWith(groupId: newGroupId);

        await _userRepository.addGroupToUser(uid, newGroupId);
      }
      yield GroupConfigurationSuccessState(configurationType: configurationType, group: group);
    } catch (_) {
      GroupFailureState(configurationType: configurationType);
    }
  }
}
