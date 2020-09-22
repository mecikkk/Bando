
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppThemes {
  static Color lightAccentColor = Color(0xff7889eb);
  static Color darkAccentColor = Color(0xff5e77ff);
  static Color lightStartColor = Color(0xff72cbf7);
  static Color darkStartColor = Color(0xff3abeff);
  static Color lightSecondAccentColor = Color(0xfffa78ad);
  static Color darkSecondAccentColor = Color(0xffff5d9f);
  static Color darkPositiveGreenColor = Color.fromRGBO(3, 252, 119, 1.0);
  static Color lightPositiveGreenColor = Color(0xff3cc27a);
  static Color errorColorLight = Color.fromRGBO(230, 48, 75, 1.0);
  static Color errorColorDark = Color.fromRGBO(227, 57, 82, 1.0);


  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    accentColor: AppThemes.lightAccentColor,
    backgroundColor: Color(0xfff3f4f9),
    scaffoldBackgroundColor: Color(0xfff3f4f9),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: 'Varela',
    dividerColor: Colors.black12,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    accentColor: AppThemes.darkAccentColor,
    backgroundColor: Color(0xff27272b),
    scaffoldBackgroundColor: Color(0xff27272b),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: 'Varela',
    dividerColor: Colors.white10,

  );

  static Color getPositiveGreenColor(BuildContext context) {
    if(Theme.of(context).brightness == Brightness.light) return lightPositiveGreenColor;
    else return darkPositiveGreenColor;
  }

  static Color getErrorColor(BuildContext context) {
    if(Theme.of(context).brightness == Brightness.light) return errorColorLight;
    else return errorColorDark;
  }

  static bool isLightTheme(BuildContext context) {
    return (Theme.of(context).brightness == Brightness.light);
  }

  static RadialGradient getGradient(BuildContext context, AlignmentGeometry begin, AlignmentGeometry end) {
    return RadialGradient(
        radius: 2.5,
        stops: [0.0, 0.4, 0.4, 0.8],
        center: Alignment.topRight,
        colors: [getSecondAccentColor(context), getAccentColor(context), getAccentColor(context), getStartColor(context)]);
  }

  static Color getStartColor(BuildContext context) {
    return (Theme.of(context).brightness == Brightness.light) ? lightStartColor : darkStartColor;
  }

  static Color getAccentColor(BuildContext context) {
    return (Theme.of(context).brightness == Brightness.light) ? lightAccentColor : darkAccentColor;
  }

  static Color getSecondAccentColor(BuildContext context) {
    return (Theme.of(context).brightness == Brightness.light) ? lightSecondAccentColor : darkSecondAccentColor;
  }
}