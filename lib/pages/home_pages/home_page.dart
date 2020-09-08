import 'package:bando/blocs/group_bloc/group_bloc.dart';
import 'package:bando/blocs/home_bloc/home_bloc.dart';
import 'package:bando/repositories/firebase_storage_repository.dart';
import 'package:bando/repositories/firestore_group_repository.dart';
import 'package:bando/repositories/firestore_user_repository.dart';
import 'package:bando/repositories/realtime_database_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koin_flutter/koin_flutter.dart';
import 'member_home_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Future<void> initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Brightness _systemNavIcons;
    debugPrint("Brightness : ${Theme.of(context).brightness}");
    if (Theme.of(context).brightness == Brightness.light)
      _systemNavIcons = Brightness.dark;
    else
      _systemNavIcons = Brightness.light;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
          systemNavigationBarIconBrightness: _systemNavIcons),
    );

    return Scaffold(
        body: MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
            create: (context) => HomeBloc(
                  groupRepository: get<FirestoreGroupRepository>(),
                  userRepository: get<FirestoreUserRepository>(),
                  storageRepository: get<FirebaseStorageRepository>(),
                  databaseRepository: get<RealtimeDatabaseRepository>(),
                )),
        BlocProvider<GroupBloc>(
            create: (context) => GroupBloc(
                  userRepository: get<FirestoreUserRepository>(),
                  groupRepository: get<FirestoreGroupRepository>(),
                )),
      ],
      child: MemberHomePage(),
    ));
  }
}
