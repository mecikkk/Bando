import 'package:bando/core/entities/group.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'file:///D:/Android/Bando/FlutterProject/bando/lib/features/home/domain/repositories/group_repository.dart';

class JoinToExistingGroupUseCase {
  final GroupRepository _groupRepository;

  JoinToExistingGroupUseCase(this._groupRepository);

  Future<Either<Failure, Group>> call({@required User user, @required String groupId}) async {
    return await _groupRepository.joinToExistingGroup(user, groupId);
  }
}