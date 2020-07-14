import 'package:bando/auth/entities/group_entity.dart';
import 'package:bando/auth/models/group_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreGroupRepository {

  final groupCollection = Firestore.instance.collection("groups");

  Future<String> createNewGroup(Group group) async {
    return await groupCollection.add(group.toEntity().toDocument()).then((value) => value.documentID);
  }

  Future<void> addUserToGroup(String groupId, String uid) async {
    Group group = await getGroup(groupId);
    group.members.add(uid);

    return groupCollection.document(groupId).setData(group.toEntity().toDocument());
  }

  Future<Group> getGroup(String groupId) async {
    return Group.fromEntity(GroupEntity.fromSnapshot(await groupCollection.document(groupId).get()));
  }

}