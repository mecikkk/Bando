import 'package:bando/models/database_lyrics_file_info_model.dart';
import 'package:bando/models/file_model.dart';
import 'package:bando/models/group_model.dart';
import 'package:bando/models/user_model.dart' as BandoUser;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FirestoreGroupRepository {
  final groupCollection = FirebaseFirestore.instance.collection("groups");

  Future<String> createNewGroup(Group group) async {
    try {
      return await groupCollection.add(group.toDocument()).then((value) => value.id);
    } on Exception catch (e) {
      debugPrint("-- GroupRepository | CreateNewGroup error : $e");
      return '';
    }
  }

  Future<Group> addUserToGroup(String groupId, BandoUser.User user) async {
    try {
      Group group = await getGroup(groupId);

      // Add groupId claim for firebase storage rules
      await CloudFunctions.instance
          .getHttpsCallable(functionName: "addGroupToken")
          .call(<String, dynamic>{"groupId": groupId, "uid": user.uid});

      User fUser = FirebaseAuth.instance.currentUser;
      await fUser.getIdTokenResult(true);

      group.members.add(user.toMap());

      await groupCollection.doc(groupId).set(group.toDocument());

      return group;
    } on Exception catch (e) {
      debugPrint("-- GroupRepository | AddUserToGroup error : $e");
      return null;
    }
  }

  Future<Group> getGroup(String groupId) async {
    try {
      DocumentSnapshot doc = await groupCollection.doc(groupId).get();

      return Group.fromSnapshot(doc);
    } on Exception catch (e) {
      debugPrint("-- GroupRepository | GetGroup error : $e");
      return null;
    }
  }

  Future<void> updateLyricsFilesInfo(List<DatabaseLyricsFileInfo> downloadUrls) async {
    try {
      String groupId = await _getCurrentUserGroupId();

      downloadUrls.forEach((element) async {
        await groupCollection.doc(groupId).collection('songbook').doc().set(element.toJson());
      });
    } on Exception catch (e) {
      debugPrint("-- GroupRepository | UpdateLyricsFilesInfo error : $e");
    }
  }

  Future<void> deleteLyricsFilesInfo(List<FileModel> deletedFiles) async {
    try {
      String groupId = await _getCurrentUserGroupId();

      for (var file in deletedFiles) {
        if (file.isDirectory) {
          QuerySnapshot snapshot = await groupCollection
              .doc(groupId)
              .collection('songbook')
              .where('localPath',
                  isGreaterThanOrEqualTo: file.fileName(), isLessThanOrEqualTo: "${file.fileName()}\uf8ff")
              .get();

          for (DocumentSnapshot doc in snapshot.docs) {
            await doc.reference.delete();
          }
        } else {
          QuerySnapshot snapshot = await groupCollection
              .doc(groupId)
              .collection('songbook')
              .where('localPath', isEqualTo: file.localPath)
              .get();

          for (DocumentSnapshot doc in snapshot.docs) {
            await doc.reference.delete();
          }
        }
      }
    } on Exception catch (e) {
      debugPrint("-- GroupRepository | DeleteLyricsFilesInfo error : $e");
    }
  }

  Future<void> changeMemberUsername(String newUsername) async {
    try {
      User fUser = FirebaseAuth.instance.currentUser;
      IdTokenResult token = await fUser.getIdTokenResult();
      DocumentSnapshot group = await groupCollection.doc(token.claims['groupId']).get();

      List<dynamic> members = group.data()['members'];
      members.firstWhere((element) => element['uid'] == fUser.uid);

      for (Map<String, dynamic> element in members) {
        if (element['uid'] == fUser.uid) element['username'] = newUsername;
      }
      return await groupCollection.doc(token.claims['groupId']).update({'members': members});
    } catch (e) {
      debugPrint("-- GroupRepository | ChangeMemberUsername error : $e");
    }
  }

  Future<List<DatabaseLyricsFileInfo>> getAllLyricsFilesInfo() async {
    List<DatabaseLyricsFileInfo> lyricsFilesInfo = List();

    try {
      String groupId = await _getCurrentUserGroupId();

      QuerySnapshot querySnapshot = await groupCollection.doc(groupId).collection('songbook').get();

      for (var doc in querySnapshot.docs) lyricsFilesInfo.add(DatabaseLyricsFileInfo.fromSnapshot(doc));

      return lyricsFilesInfo;
    } on Exception catch (e) {
      debugPrint("-- GroupRepository | GetAllLyricsFilesInfo error : $e");
      return List();
    }
  }

  Future<void> setLeader(String newLeaderId) async {
    try {
      String groupId = await _getCurrentUserGroupId();

      return await groupCollection.doc(groupId).update({"leaderId": newLeaderId});
    } on Exception catch (e) {
      debugPrint("-- GroupRepository | SetLeader error : $e");
    }
  }

  Future<String> getLeader() async {
    try {
      String groupId = await _getCurrentUserGroupId();

      DocumentSnapshot doc = await groupCollection.doc(groupId).get();
      return doc.data()["leaderId"];
    } on Exception catch (e) {
      debugPrint("-- GroupRepository | GetLeader error : $e");
    }

    return "";
  }

  Future<String> _getCurrentUserGroupId() async {
    try {
      User fUser = FirebaseAuth.instance.currentUser;
      IdTokenResult token = await fUser.getIdTokenResult(true);

      return token.claims['groupId'];
    } on Exception catch (e) {
      debugPrint("-- GroupRepository | GetCurrentUserGroupId error : $e");
    }

    return "";
  }
}
