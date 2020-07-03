import 'package:bando/home/pages/home_page.dart';
import 'package:bando/utils/consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {



  @override
  Widget build(BuildContext context) {

    Brightness _systemNavIcons;
    debugPrint("Brightness : ${Theme.of(context).brightness}");
    if(Theme.of(context).brightness == Brightness.light) _systemNavIcons = Brightness.dark;
    else _systemNavIcons = Brightness.light;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
          systemNavigationBarIconBrightness: _systemNavIcons
      ),
    );

    return MaterialApp(
      title: 'Bando',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        accentColor: Constants.lightAccentColor,
        scaffoldBackgroundColor: Color(0xfff3f4f9),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Varela',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Constants.darkAccentColor,
        scaffoldBackgroundColor: Color(0xff2B2B2B),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Varela',
      ),
      home: HomePage(title: "Bando",),
    );
  }
}
