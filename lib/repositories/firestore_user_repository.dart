import 'package:bando/auth/entities/user_entity.dart';
import 'package:bando/auth/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreUserRepository{

  final usersCollection = Firestore.instance.collection("users");

  Future<void> addNewUser(User user) {
    return usersCollection.document(user.uid).setData(user.toEntity().toDocument());
  }

  Future<void> deleteUser(User user) {
    return usersCollection.document(user.uid).delete();
  }

  Future<void> updateUser(User user) {
    return usersCollection.document(user.uid).updateData(user.toEntity().toDocument());
  }

  Future<void> addGroupToUser(String uid, String groupId) async {
    User user = await getUser(uid);
    user.groupId = groupId;
    return usersCollection.document(uid).updateData(user.toEntity().toDocument());
  }

  Future<User> getUser(String uid) async {
    return User.fromEntity(UserEntity.fromSnapshot(await usersCollection.document(uid).get()));
  }

  Future<String> currentUserId() async {
    return FirebaseAuth.instance.currentUser().then((value) => value.uid);
  }

  Future<User> currentUser() async {
    String uid = await currentUserId();
    return await getUser(uid);
  }

  Future<String> getUserGroupId() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot snapshot = await usersCollection.document(user.uid).get();
    return snapshot.data["groupId"];
  }

  Future<bool> isUserGroupConfigured(String uid) async {
    DocumentSnapshot snapshot = await usersCollection.document(uid).get();
    return (snapshot.data["groupId"] == "") ? false : true;
  }

}