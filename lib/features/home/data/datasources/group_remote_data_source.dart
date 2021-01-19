import 'package:bando/core/entities/user.dart';
import 'package:bando/core/errors/failure.dart';
import 'package:bando/features/home/data/models/group_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire;
import 'package:flutter/foundation.dart';

abstract class GroupRemoteDataSource {
  Future<Either<Failure, GroupModel>> getGroup(String groupId);

  Future<Either<Failure, GroupModel>> createNewGroup(User user, String groupName);

  Future<Either<Failure, GroupModel>> joinToExistingGroup(User user, String groupId);

  Future<Either<Failure, GroupModel>> changeLeader(String newLeaderId);

  Future<Either<Failure, GroupModel>> updateMemberData(User user);
}

class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  final fire.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  GroupRemoteDataSourceImpl(this._firebaseAuth, this._firestore);

  @override
  Future<Either<Failure, GroupModel>> changeLeader(String newLeaderId) async {
    try {
      final tokenResult = await _firebaseAuth.currentUser.getIdTokenResult();
      String groupId = tokenResult.claims['groupId'];

      final ref = _firestore.collection('groups').doc(groupId);

      await ref.update({"leaderId": newLeaderId});

      final snapshot = await ref.get();

      return Right(GroupModel.fromSnapshot(snapshot));

    } on Exception catch (e) {
      debugPrint("Changing leader error : $e");
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, GroupModel>> createNewGroup(User user, String groupName) async {
    try {
      final group = GroupModel(name: groupName, leaderId: user.uid, members: [user]);
      final groupId = await _firestore.collection("groups").add(group.toJson()).then((value) => value.id);

      // Add groupId claim
      if (user.groupId == '')
        await FirebaseFunctions.instance
          .httpsCallable("addGroupToken")
          .call(<String, dynamic>{"groupId": groupId, "uid": user.uid});

      fire.User fUser = _firebaseAuth.currentUser;
      await fUser.getIdTokenResult(true);

      return Right(group);
    } on Exception catch (e) {
      debugPrint("Creating group error : $e");
      return Left(CreatingNewGroupFailure());
    }
  }

  @override
  Future<Either<Failure, GroupModel>> getGroup(String groupId) async {
    try {
      final groupSnapshot = await _firestore.collection('groups').doc(groupId).get();

      final group = GroupModel.fromSnapshot(groupSnapshot);

      return Right(group);
    } on Exception catch (e) {
      debugPrint("Getting group error : $e");
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, GroupModel>> joinToExistingGroup(User user, String groupId) async {
    try {
      final groupSnapshot = await _firestore.collection('groups').doc(groupId).get();
      final group = GroupModel.fromSnapshot(groupSnapshot);

      group.members.add(user);

      await _firestore.collection('groups').doc(groupId).update(group.toJson());

      // Add groupId claim
      if (user.groupId == '')
        await FirebaseFunctions.instance
            .httpsCallable("addGroupToken")
            .call(<String, dynamic>{"groupId": groupId, "uid": user.uid});

      fire.User fUser = _firebaseAuth.currentUser;
      await fUser.getIdTokenResult(true);

      return Right(group);
    } on Exception catch (e) {
      debugPrint("Joining to existing group error : $e");
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, GroupModel>> updateMemberData(User user) async {
    try {
      final groupSnapshot = await _firestore.collection('groups').doc(user.groupId).get();
      final group = GroupModel.fromSnapshot(groupSnapshot);

      group.members.add(user);

      await _firestore.collection('groups').doc(user.groupId).update(group.toJson());

      return Right(group);
    } on Exception catch (e) {
      debugPrint("Updating member data error : $e");
      return Left(ServerFailure());
    }
  }
}
