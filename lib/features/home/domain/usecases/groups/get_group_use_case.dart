import 'package:bando/core/entities/group.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'file:///D:/Android/Bando/FlutterProject/bando/lib/features/home/domain/repositories/group_repository.dart';

class GetGroupUseCase {
  final GroupRepository groupRepository;

  GetGroupUseCase(this.groupRepository);

  Future<Either<Failure, Group>> call({@required String groupId}) async {
    return await groupRepository.getGroupById(groupId);
  }
}
