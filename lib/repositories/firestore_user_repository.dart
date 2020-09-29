import 'package:bando/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreUserRepository {
  final usersCollection = Firestore.instance.collection("users");

  Future<void> addNewUser(User user) {
    return usersCollection.document(user.uid).setData(user.toDocument());
  }

  Future<void> deleteUser(User user) {
    return usersCollection.document(user.uid).delete();
  }

  Future<void> updateUser(User user) {
    return usersCollection.document(user.uid).updateData(user.toDocument());
  }

  Future<void> addGroupToUser(String uid, String groupId) async {
    User user = await getUser(uid);
    user.groupId = groupId;

    return usersCollection.document(uid).updateData(user.toDocument());
  }

  Future<String> getCurrentUserName() async {
    User u = await currentUser();
    return u.username;
  }

  Future<String> getCurrentUserGroupId() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    IdTokenResult token = await user.getIdToken();
    return token.claims["groupId"];
  }

  Future<User> getUser(String uid) async {
    return User.fromSnapshot(await usersCollection.document(uid).get());
  }

  Future<String> currentUserId() async {
    return FirebaseAuth.instance.currentUser().then((value) => value.uid);
  }

  Future<void> setLastUpdateTime(int lastUpdate) async {
    String uid = await currentUserId();

    return await usersCollection.document(uid).updateData(
      {"lastUpdate" : lastUpdate}
    );

  }

  Future<int> getLastUpdateTime() async {
    String uid = await currentUserId();
    DocumentSnapshot snap = await usersCollection.document(uid).get();

    return snap.data["lastUpdate"] as int;
  }

  Future<User> currentUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    User user;

    if (pref.getString('username') == null || pref.getString('uid') == null) {
      String uid = await currentUserId();
      User user = await getUser(uid);
      await pref.setString('username', user.username);
      await pref.setString('uid', user.uid);
      if (user.groupId != "") pref.setString('groupId', user.groupId);
    } else {
      user = User(
        pref.getString('uid'),
        username: pref.getString('username'),
        groupId: pref.getString('groupId') ?? '',
      );
    }

    return user;
  }

  Future<bool> isUserGroupConfigured(String uid) async {
    DocumentSnapshot snapshot = await usersCollection.document(uid).get();
    return (snapshot.data["groupId"] == "") ? false : true;
  }
}
