import 'package:bando/features/authorization/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:koin/koin.dart';

class GenerateScreen {
  final Koin _koin;

  GenerateScreen(this._koin);

  Route<dynamic> onGenerate(RouteSettings settings) {
    switch (settings.name) {
      case Pages.SPLASH:
        return MaterialPageRoute(builder: (context) => SplashPage());
      default:
        return null;
    }
  }
}

class Pages {
  static const String SPLASH = '/';
}
