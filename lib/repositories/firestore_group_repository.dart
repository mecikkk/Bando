import 'package:bando/entities/database_lyrics_file_info_entity.dart';
import 'package:bando/entities/group_entity.dart';
import 'package:bando/models/database_lyrics_file_info_model.dart';
import 'package:bando/models/group_model.dart';
import 'package:bando/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreGroupRepository {

  final groupCollection = Firestore.instance.collection("groups");

  Future<String> createNewGroup(Group group) async {
    return await groupCollection.add(group.toEntity().toDocument()).then((value) => value.documentID);
  }

  Future<Group> addUserToGroup(String groupId, User user) async {
    Group group = await getGroup(groupId);

    // Add groupId claim for firebase storage rules
    HttpsCallableResult result = await CloudFunctions.instance
        .getHttpsCallable(functionName: "addGroupToken")
        .call(<String, dynamic>{"groupId": groupId, "uid": user.uid});


    FirebaseUser fUser = await FirebaseAuth.instance.currentUser();

    IdTokenResult tokenResult = await fUser.getIdToken(refresh: true);

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

  Future<void> updateLyricsFilesInfo(List<DatabaseLyricsFileInfo> downloadUrls, String groupId) async {
    downloadUrls.forEach((element) async {
      await groupCollection.document(groupId).collection('songbook').document().setData(
        element.toEntity().toJson()
      );
    });

//
//    return groupCollection.document(groupId).updateData({
//      'songbookUrls' : downloadUrls
//    });
  }

  Future<List<DatabaseLyricsFileInfo>> getAllLyricsFilesInfo(String groupId) async {
    List<DatabaseLyricsFileInfo> lyricsFilesInfo = List();

    QuerySnapshot querySnapshot = await groupCollection.document(groupId).collection('songbook').getDocuments();

    for(var doc in querySnapshot.documents)
      lyricsFilesInfo.add(DatabaseLyricsFileInfo.fromEntity(DatabaseLyricsFileInfoEntity.fromSnapshot(doc)));

    return lyricsFilesInfo;
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