import 'package:bando/models/user_model.dart' as BandoUser;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreUserRepository {
  final usersCollection = FirebaseFirestore.instance.collection("users");

  Future<void> addNewUser(BandoUser.User user) async {
    return usersCollection.doc(user.uid).set(user.toDocument());
  }

  Future<void> deleteUser(BandoUser.User user) {
    return usersCollection.doc(user.uid).delete();
  }

  Future<void> updateUser(BandoUser.User user) {
    return usersCollection.doc(user.uid).update(user.toDocument());
  }

  Future<void> changeUsername(String newUsername) async {
    User fUser = FirebaseAuth.instance.currentUser;

    SharedPreferences _pref = await SharedPreferences.getInstance();
    _pref.setString('username', newUsername);

    return await usersCollection.doc(fUser.uid).update({'username': newUsername});
  }

  Future<void> addGroupToUser(String uid, String groupId) async {
    BandoUser.User user = await getUser(uid);
    user.groupId = groupId;

    return usersCollection.doc(uid).update(user.toDocument());
  }

  Future<String> getCurrentUserName() async {
    BandoUser.User u = await currentUser();
    return u.username;
  }

  Future<String> getCurrentUserGroupId() async {
    User user = FirebaseAuth.instance.currentUser;
    IdTokenResult token = await user.getIdTokenResult();

    debugPrint("------------ GROUP ID FROM TOKEN : ${token.claims["groupId"]}");
    return token.claims["groupId"];
  }

  Future<BandoUser.User> getUser(String uid) async {
    return BandoUser.User.fromSnapshot(await usersCollection.doc(uid).get());
  }

  Future<String> currentUserId() async {
    return FirebaseAuth.instance.currentUser.uid;
  }

  Future<void> setLastUpdateTime(int lastUpdate) async {
    String uid = await currentUserId();

    return await usersCollection.doc(uid).update({"lastUpdate": lastUpdate});
  }

  Future<int> getLastUpdateTime() async {
    String uid = await currentUserId();
    DocumentSnapshot snap = await usersCollection.doc(uid).get();

    return snap.data()["lastUpdate"] as int;
  }

  Future<BandoUser.User> currentUser() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      BandoUser.User user;

      if (pref.getString('username') == null || pref.getString('uid') == null) {
        String uid = await currentUserId();
        user = await getUser(uid);

        pref.setString('username', user.username);
        pref.setString('uid', user.uid);
        if (user.groupId != "") pref.setString('groupId', user.groupId);
      } else {
        String groupId;
        String prefGroupId = pref.getString('groupId');

        groupId = (prefGroupId == null) ? await getCurrentUserGroupId() : prefGroupId;

        user = await compute(_getUserFromSharedPreferences, {"pref": pref, "groupId": groupId});
        // user = User(
        //   pref.getString('uid'),
        //   username: pref.getString('username'),
        //   groupId: groupId,
        // );
      }

      return user;
    } on Exception catch (e) {
      debugPrint("--- UserRepository | CurrentUser error : $e");
      return null;
    }
  }

  Future<bool> isUserGroupConfigured(String uid) async {
    DocumentSnapshot snapshot = await usersCollection.doc(uid).get();
    return (snapshot.data()["groupId"] == "") ? false : true;
  }
}

Future<BandoUser.User> _getUserFromSharedPreferences(Map params) async {
  SharedPreferences pref = params["pref"];
  String groupId = params["groupId"];

  return BandoUser.User(
    pref.getString('uid'),
    username: pref.getString('username'),
    groupId: groupId,
  );
}
