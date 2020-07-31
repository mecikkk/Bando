import 'package:bando/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:bando/auth/pages/login_page.dart';
import 'file:///D:/Android/Bando/FlutterProject/bando/lib/repositories/auth_repository.dart';
import 'package:bando/bloc_observer.dart';
import 'package:bando/dependency_injection.dart';
import 'package:bando/home/pages/home_page.dart';
import 'package:bando/utils/consts.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koin/koin.dart';

import 'file_manager/utils/files_utils.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleBlocObserver();

  var koin = startKoin((app) {
    app.printLogger(level: Level.debug);
    app.module(authModule);
  }).koin;

  runApp(
    BlocProvider(
        create: (context) => AuthBloc(authRepository: koin.get<AuthRepository>())..add(AuthStarted()), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  Widget currentPage;

  @override
  Widget build(BuildContext context) {
    FilesUtils.generateSongbookDirectory();

    Brightness _systemNavIcons;
    if (Theme.of(context).brightness == Brightness.light)
      _systemNavIcons = Brightness.dark;
    else
      _systemNavIcons = Brightness.light;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
          systemNavigationBarIconBrightness: _systemNavIcons),
    );

    currentPage = _buildHeader();

    return MaterialApp(
      title: 'Bando',
      debugShowCheckedModeBanner: false,
      theme: Constants.lightTheme,
      darkTheme: Constants.darkTheme,
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {

          swapPages(state);

          return AnimatedSwitcher(
                  duration: Duration(milliseconds: 800),
                  child: currentPage,
          );
        },
      ),
    );
  }

  void swapPages(AuthState state) {
    if (state is Unauthenticated)
      currentPage = LoginPage(
      );
    else if (state is Authenticated) {
      currentPage = HomePage(
        title: "Bando",
      );
    } else {
      currentPage = _buildHeader(
      );
    }
  }

  Widget _buildHeader() {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 30, bottom: 10),
                child: Image.asset(
                  "assets/logo_gradient.png",
                  scale: 8,
                  height: 120,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
