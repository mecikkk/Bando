import 'package:bando/core/entities/group.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'file:///D:/Android/Bando/FlutterProject/bando/lib/features/home/domain/repositories/group_repository.dart';

class UpdateMemberDataUseCase {
  final GroupRepository groupRepository;

  UpdateMemberDataUseCase(this.groupRepository);

  Future<Either<Failure, Group>> call({@required User user}) async {
    return await groupRepository.updateMemberData(user);
  }
}