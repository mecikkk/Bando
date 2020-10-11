import 'package:bando/bloc_observer.dart';
import 'package:bando/blocs/login_bloc/login_bloc.dart';
import 'package:bando/blocs/udp/udp_bloc.dart';
import 'package:bando/dependency_injection.dart';
import 'package:bando/pages/auth/login_page.dart';
import 'package:bando/pages/home/home_page.dart';
import 'package:bando/utils/app_themes.dart';
import 'package:bando/utils/util.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:koin/koin.dart';

import 'blocs/auth_bloc/auth_bloc.dart';
import 'blocs/group_bloc/group_bloc.dart';
import 'blocs/home_bloc/home_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleBlocObserver();

  var koin = startKoin((app) {
    app.printLogger(level: Level.debug)..modules([repositoriesModule, blocsModule]);
  }).koin;

  runApp(
    BlocProvider(
      create: (context) => koin.get<AuthBloc>()..add(AuthStarted()),
      child: ProviderScope(child: BandoApp(koin: koin)),
    ),
  );
}

class BandoApp extends StatelessWidget {
  final Koin koin;

  BandoApp({@required this.koin});

  @override
  Widget build(BuildContext context) {
    updateStatusbarAndNavBar(context, showWhiteStatusBarIcons: !AppThemes.isLightTheme(context));

    return MaterialApp(
      title: 'Bando',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          debugPrint("AuthCurrentState : $state");
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 800),
            child: _swapPages(state, context),
          );
        },
      ),
    );
  }

  Widget _swapPages(AuthState state, BuildContext context) {
    if (state is Unauthenticated)
      return _buildLoginPage();
    else if (state is AuthLoggedOutState)
      return _buildLoginPage();
    else if (state is Authenticated) {
      return _buildHomePage();
    } else if (state is AuthLoggedInState) {
      return _buildHomePage();
    } else {
      return _buildSplashScreen(context);
    }
  }

  Widget _buildSplashScreen(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 30, bottom: 10),
                  child: Image.asset(
                    "assets/logo_gradient.png",
                    height: 170,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 4.0, top: 16.0),
                  child: Text(
                    "Bando",
                    style: TextStyle(fontSize: 38.0, letterSpacing: 0),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 28.0, left: 3),
                  child: Text(
                    "Zsynchronizuj śpiewnik zespołowy ♫",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomePage() => MultiBlocProvider(
          providers: [
            BlocProvider<HomeBloc>(create: (context) => koin.get<HomeBloc>()),
            BlocProvider<GroupBloc>(create: (context) => koin.get<GroupBloc>()),
            BlocProvider<UdpBloc>(create: (context) => koin.get<UdpBloc>()),
          ],
          child: HomePage(),
        );

  Widget _buildLoginPage() => MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(create: (context) => koin.get<LoginBloc>()),
      ],
      child: LoginPage(),
    );

}
