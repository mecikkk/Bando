import 'package:bando/core/utils/localization.dart';
import 'package:flutter/material.dart';

extension ThemeContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Returns __bodyText1__ color from app theme
  Color get textColor => Theme.of(this).textTheme.bodyText1.color;

  /// Returns __scaffoldBackgroundColor__ from app theme
  Color get bgColor => Theme.of(this).scaffoldBackgroundColor;

  /// Returns __true__ when app (system) theme is light/day
  ///
  /// or __false__ when theme is dark/night
  bool get isLightTheme => (Theme.of(this).brightness == Brightness.dark);

  /// Returns scaled value for small devices
  double scale(double value) => (MediaQuery.of(this).size.shortestSide >= 480) ? value : (0.8 * value);
}

extension MediaQueryExt on BuildContext {
  double get shortestSideSize => MediaQuery.of(this).size.shortestSide;
  double get longestSideSize => MediaQuery.of(this).size.longestSide;
  double get height => MediaQuery.of(this).size.height;
  double get width => MediaQuery.of(this).size.width;
}

extension ContextExt on BuildContext {
  /// Returns translated string from JSON file located in __lang__ dir
  String translate(String value) => AppLocalizations.of(this).translate(value);
}

extension BandoColorScheme on ColorScheme {
  Color get success => brightness == Brightness.light ? Color(0xff29b369) : Color.fromRGBO(3, 252, 119, 1.0);
  Color get failure => brightness == Brightness.light ? Color.fromRGBO(230, 48, 75, 1.0) : Color.fromRGBO(227, 57, 82, 1.0);
  Color get first => brightness == Brightness.light ? Color(0xff5f74de) : Color(0xff677deb);
  Color get second => brightness == Brightness.light ? Color(0xff925bde) : Color(0xffa571f0);
  Color get accent => brightness == Brightness.light ? Color(0xffd9558a) : Color(0xfff26f99);
}