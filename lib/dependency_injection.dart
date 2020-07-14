import 'package:bando/auth/repository/auth_repository.dart';
import 'package:bando/auth/repository/firestore_group_repository.dart';
import 'package:bando/auth/repository/firestore_user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koin/koin.dart';

var authModule = Module()
    ..single<AuthRepository>((scope) => AuthRepository(firebaseAuth: FirebaseAuth.instance))
    ..single<FirestoreUserRepository>((scope) => FirestoreUserRepository())
    ..single<FirestoreGroupRepository>((scope) => FirestoreGroupRepository());