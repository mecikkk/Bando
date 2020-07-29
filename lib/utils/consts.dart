
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Constants {
  static Color lightAccentColor = Color.fromRGBO(106, 61, 255, 1.0);
  static Color darkAccentColor = Color.fromRGBO(143, 110, 255, 1.0);
  static Color lightSecondAccentColor = Color.fromRGBO(189, 51, 86, 1.0);
  static Color darkSecondAccentColor = Color.fromRGBO(201, 73, 88, 1.0);
  static Color positiveGreenColor = Color.fromRGBO(3, 252, 119, 1.0);
  static Color errorColorLight = Color.fromRGBO(230, 48, 75, 1.0);
  static Color errorColorDark = Color.fromRGBO(227, 57, 82, 1.0);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    accentColor: Constants.lightAccentColor,
    scaffoldBackgroundColor: Color(0xfff3f4f9),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: 'Varela',
    dividerColor: Colors.black45,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    accentColor: Constants.darkAccentColor,
    scaffoldBackgroundColor: Color(0xff2B2B2B),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: 'Varela',
    dividerColor: Colors.white38,

  );

  static Color getErrorColor(BuildContext context) {
    if(Theme.of(context).brightness == Brightness.light) return errorColorLight;
    else return errorColorDark;
  }

  static bool isLightTheme(BuildContext context) {
    return (Theme.of(context).brightness == Brightness.light);
  }

  static updateNavBarTheme(BuildContext context) {
    Brightness _systemNavIcons;
    if(Theme.of(context).brightness == Brightness.light) _systemNavIcons = Brightness.dark;
    else _systemNavIcons = Brightness.light;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
          systemNavigationBarIconBrightness: _systemNavIcons
      ),
    );
  }

  static LinearGradient getGradient(BuildContext context, AlignmentGeometry begin, AlignmentGeometry end) {
    return LinearGradient(
        begin: begin,
        end: end,
        colors: [getStartGradientColor(context), getEndGradientColor(context)]);
  }

  static Color getStartGradientColor(BuildContext context) {
    return (Theme.of(context).brightness == Brightness.light) ? lightAccentColor : darkAccentColor;
  }

  static Color getEndGradientColor(BuildContext context) {
    return (Theme.of(context).brightness == Brightness.light) ? lightSecondAccentColor : darkSecondAccentColor;
  }
}