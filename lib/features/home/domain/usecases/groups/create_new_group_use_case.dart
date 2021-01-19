import 'package:bando/core/entities/group.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'file:///D:/Android/Bando/FlutterProject/bando/lib/features/home/domain/repositories/group_repository.dart';

class CreateNewGroupUseCase {
  final GroupRepository groupRepository;

  CreateNewGroupUseCase(this.groupRepository);

  Future<Either<Failure, Group>> call({@required User user, @required String groupName}) async {
    return await groupRepository.createNewGroup(user, groupName);
  }
}