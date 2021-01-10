import 'package:bando/features/authorization/presentation/blocs/registration/registration_bloc.dart';
import 'package:bando/features/authorization/presentation/pages/registration_page.dart';
import 'package:bando/features/authorization/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koin/koin.dart';

class GenerateScreen {
  final Koin _koin;

  GenerateScreen(this._koin);

  Route<dynamic> onGenerate(RouteSettings settings) {
    switch (settings.name) {
      case Pages.SPLASH:
        return MaterialPageRoute(builder: (context) => SplashPage());
      case Pages.REGISTRATION:
        return MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value : _koin.get<RegistrationBloc>(),
            child: RegistrationPage(),
          ),
        );
      default:
        return null;
    }
  }
}

class Pages {
  static const String SPLASH = '/';
  static const String REGISTRATION = 'registration_page';
}
