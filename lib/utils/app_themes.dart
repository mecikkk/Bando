import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppThemes {
  static Color lightAccentColor = Color(
      0xff925bde);
  static Color darkAccentColor = Color(
      0xffa571f0);
  static Color lightStartColor = Color(
      0xff5f74de);
  static Color darkStartColor = Color(
      0xff677deb);
  static Color lightSecondAccentColor = Color(
      0xffd9558a);
  static Color darkSecondAccentColor = Color(
      0xfff26f99);
  static Color darkPositiveGreenColor = Color.fromRGBO(
      3, 252, 119, 1.0);
  static Color lightPositiveGreenColor = Color(
      0xff29b369);
  static Color errorColorLight = Color.fromRGBO(
      230, 48, 75, 1.0);
  static Color errorColorDark = Color.fromRGBO(
      227, 57, 82, 1.0);


  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    accentColor: AppThemes.lightAccentColor,
    backgroundColor: Color(
        0xfff3f4f9),
    scaffoldBackgroundColor: Color(
        0xfff3f4f9),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: 'Varela',
    dividerColor: Colors.black12,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    accentColor: AppThemes.darkAccentColor,
    backgroundColor: Color(
        0xff27272b),
    scaffoldBackgroundColor: Color(
        0xff27272b),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: 'Varela',
    dividerColor: Colors.white10,

  );

  static Color getPositiveGreenColor(BuildContext context) {
    if (Theme
        .of(
        context)
        .brightness == Brightness.light)
      return lightPositiveGreenColor;
    else
      return darkPositiveGreenColor;
  }

  static Color getErrorColor(BuildContext context) {
    if (Theme
        .of(
        context)
        .brightness == Brightness.light)
      return errorColorLight;
    else
      return errorColorDark;
  }

  static bool isLightTheme(BuildContext context) {
    return (Theme
        .of(
        context)
        .brightness == Brightness.light);
  }

  static RadialGradient getGradient(BuildContext context, AlignmentGeometry begin, AlignmentGeometry end) {
    return RadialGradient(
        radius: 2.5,
        stops: [0.0, 0.4, 0.4, 0.8],
        colors: [getSecondAccentColor(
            context), getAccentColor(
            context), getAccentColor(
            context), getStartColor(
            context)
        ],
        center: Alignment.topRight);
  }

  static Color getStartColor(BuildContext context) {
    return (Theme
        .of(
        context)
        .brightness == Brightness.light) ? lightStartColor : darkStartColor;
  }

  static Color getAccentColor(BuildContext context) {
    return (Theme
        .of(
        context)
        .brightness == Brightness.light) ? lightAccentColor : darkAccentColor;
  }

  static Color getSecondAccentColor(BuildContext context) {
    return (Theme
        .of(
        context)
        .brightness == Brightness.light) ? lightSecondAccentColor : darkSecondAccentColor;
  }
}