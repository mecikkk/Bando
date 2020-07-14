import 'package:bando/auth/entities/user_entity.dart';
import 'package:bando/auth/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

}