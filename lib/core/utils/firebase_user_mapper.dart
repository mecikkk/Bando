import 'package:bando/features/authorization/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

extension FirebaseUserToDomain on User {
  Future<UserModel> toDomain() async {
    final tokenResult = await getIdTokenResult();
    return UserModel(uid: uid, displayName: displayName, groupId: tokenResult.claims['groupId']);
  }
}
