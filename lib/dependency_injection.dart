import 'file:///D:/Android/Bando/FlutterProject/bando/lib/repositories/auth_repository.dart';
import 'file:///D:/Android/Bando/FlutterProject/bando/lib/repositories/firestore_group_repository.dart';
import 'file:///D:/Android/Bando/FlutterProject/bando/lib/repositories/firestore_user_repository.dart';
import 'package:bando/repositories/firebase_storage_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koin/koin.dart';

var authModule = Module()
    ..single<AuthRepository>((scope) => AuthRepository(firebaseAuth: FirebaseAuth.instance))
    ..single<FirestoreUserRepository>((scope) => FirestoreUserRepository())
    ..single<FirestoreGroupRepository>((scope) => FirestoreGroupRepository())
    ..single<FirebaseStorageRepository>((scope) => FirebaseStorageRepository());