import 'package:bando/features/authorization/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';

class GenerateScreen {
  static Route<dynamic> onGenerate(RouteSettings settings) {
    switch(settings.name) {
      case Pages.LOGIN :
        return MaterialPageRoute(builder: (context) => SplashPage());
    }
  }
}

class Pages {
  static const String LOGIN = '/';
}