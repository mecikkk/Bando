import 'package:bando/blocs/auth_bloc/auth_bloc.dart';
import 'package:bando/blocs/group_bloc/group_bloc.dart';
import 'package:bando/blocs/home_bloc/home_bloc.dart';
import 'package:bando/blocs/login_bloc/login_bloc.dart';
import 'package:bando/blocs/register_bloc/register_bloc.dart';
import 'package:bando/repositories/auth_repository.dart';
import 'package:bando/repositories/firebase_storage_repository.dart';
import 'package:bando/repositories/firestore_group_repository.dart';
import 'package:bando/repositories/firestore_user_repository.dart';
import 'package:bando/repositories/realtime_database_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koin/koin.dart';

var repositoriesModule = Module()
    ..single<AuthRepository>((scope) => AuthRepository(firebaseAuth: FirebaseAuth.instance))
    ..single<FirestoreUserRepository>((scope) => FirestoreUserRepository())
    ..single<FirestoreGroupRepository>((scope) => FirestoreGroupRepository())
    ..single<FirebaseStorageRepository>((scope) => FirebaseStorageRepository())
    ..single<RealtimeDatabaseRepository>((scope) => RealtimeDatabaseRepository());

var blocsModule = Module()
    ..single<HomeBloc>((scope) => HomeBloc(userRepository : scope.get(), databaseRepository: scope.get(), groupRepository: scope.get(), storageRepository: scope.get()))
    ..single<LoginBloc>((scope) => LoginBloc(authRepository: scope.get()))
    ..single<RegisterBloc>((scope) => RegisterBloc(userRepository: scope.get(), authRepository: scope.get()))
    ..single<AuthBloc>((scope) => AuthBloc(authRepository: scope.get()))
    ..single<GroupBloc>((scope) => GroupBloc(groupRepository: scope.get(), userRepository: scope.get()));