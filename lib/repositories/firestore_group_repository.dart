import 'package:bando/auth/entities/group_entity.dart';
import 'package:bando/auth/models/group_model.dart';
import 'package:bando/auth/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreGroupRepository {

  final groupCollection = Firestore.instance.collection("groups");

  Future<String> createNewGroup(Group group) async {
    return await groupCollection.add(group.toEntity().toDocument()).then((value) => value.documentID);
  }

  Future<Group> addUserToGroup(String groupId, User user) async {
    Group group = await getGroup(groupId);
    group.members.add(user.toEntity().toMap());

    await groupCollection.document(groupId).setData(group.toEntity().toDocument());
    return group;
  }

  Future<Group> getGroup(String groupId) async {
    return Group.fromEntity(GroupEntity.fromSnapshot(await groupCollection.document(groupId).get()));
  }

  Future<void> _updateMembers(Group group) async {
    await groupCollection.document(group.groupId).updateData({
      'members' : group.members
    });
  }

  Future<void> setGroupShouldUpdateSongbook(String uid, String groupId) async {

    Group group = await getGroup(groupId);
    List<Map<String, dynamic>> members = List<Map<String, dynamic>>();
    group.members.forEach((element) {
      if(element['uid'] != uid) element['shouldUpdateFiles'] = true;
      members.add(element);
    });

    await _updateMembers(group.copyWith(members: members));
    return;
  }

  Future<void> setListOfUrls(List<String> downloadUrls, String groupId) {

    return groupCollection.document(groupId).updateData({
      'songbookUrls' : downloadUrls
    });
  }

  Future<bool> shouldUserUpdateSongbook(String uid, String groupId) async {
    bool shouldUpdate;

    Group group = await getGroup(groupId);

    group.members.forEach((element) {
      if(element['uid'] == uid) shouldUpdate = element['shouldUpdateFiles'];
    });

    return shouldUpdate;
  }

}