import 'package:bando/models/database_lyrics_file_info_model.dart';
import 'package:bando/models/file_model.dart';
import 'package:bando/models/group_model.dart';
import 'package:bando/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreGroupRepository {
  final groupCollection = Firestore.instance.collection("groups");

  Future<String> createNewGroup(Group group) async {
    return await groupCollection.add(group.toDocument()).then((value) => value.documentID);
  }

  Future<Group> addUserToGroup(String groupId, User user) async {
    Group group = await getGroup(groupId);

    // Add groupId claim for firebase storage rules
    HttpsCallableResult result = await CloudFunctions.instance
        .getHttpsCallable(functionName: "addGroupToken")
        .call(<String, dynamic>{"groupId": groupId, "uid": user.uid});

    FirebaseUser fUser = await FirebaseAuth.instance.currentUser();

    IdTokenResult tokenResult = await fUser.getIdToken(refresh: true);

    group.members.add(user.toMap());

    await groupCollection.document(groupId).setData(group.toDocument());

    return group;
  }

  Future<Group> getGroup(String groupId) async {
    return Group.fromSnapshot(await groupCollection.document(groupId).get());
  }

  Future<void> updateLyricsFilesInfo(List<DatabaseLyricsFileInfo> downloadUrls, String groupId) async {
    downloadUrls.forEach((element) async {
      await groupCollection.document(groupId).collection('songbook').document().setData(element.toJson());
    });
  }

  Future<void> deleteLyricsFilesInfo(List<FileModel> deletedFiles, String groupId) async {
    for (var file in deletedFiles) {
      if (file.isDirectory) {

        QuerySnapshot snapshot = await groupCollection
            .document(groupId)
            .collection('songbook')
            .where('localPath',
                isGreaterThanOrEqualTo: file.fileName(), isLessThanOrEqualTo: "${file.fileName()}\uf8ff")
            .getDocuments();

        for (DocumentSnapshot doc in snapshot.documents) doc.reference.delete();

      } else {
        QuerySnapshot snapshot = await groupCollection
            .document(groupId)
            .collection('songbook')
            .where('fileName', isEqualTo: file.fileName())
            .getDocuments();

        for (DocumentSnapshot doc in snapshot.documents) doc.reference.delete();
      }
    }
  }

  Future<List<DatabaseLyricsFileInfo>> getAllLyricsFilesInfo(String groupId) async {
    List<DatabaseLyricsFileInfo> lyricsFilesInfo = List();

    QuerySnapshot querySnapshot = await groupCollection.document(groupId).collection('songbook').getDocuments();

    for (var doc in querySnapshot.documents)
      lyricsFilesInfo.add(DatabaseLyricsFileInfo.fromSnapshot(doc));

    return lyricsFilesInfo;
  }

  Future<bool> shouldUserUpdateSongbook(String uid, String groupId) async {
    bool shouldUpdate;

    Group group = await getGroup(groupId);

    group.members.forEach((element) {
      if (element['uid'] == uid) shouldUpdate = element['shouldUpdateFiles'];
    });

    return shouldUpdate;
  }
}
