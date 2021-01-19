import 'package:bando/core/entities/group.dart';
import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

abstract class GroupRepository {
  Future<Either<Failure, Group>> createNewGroup(User user, String groupName);
  Future<Either<Failure, Group>> joinToExistingGroup(User user, String groupId);
  Future<Either<Failure, Group>> getGroupById(String groupId);
  Future<Either<Failure, Group>> changeLeader(String newLeaderId);
  Future<Either<Failure, Group>> updateMemberData(User user);

}