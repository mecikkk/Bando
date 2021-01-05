import 'package:bando/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';

class AppThemes {
  static BuildContext _context;

  static void setContext(BuildContext context) {
    _context = context;
  }

  static Color lightAccentColor = Color(0xff925bde);
  static Color darkAccentColor = Color(0xffa571f0);
  static Color lightStartColor = Color(0xff5f74de);
  static Color darkStartColor = Color(0xff677deb);
  static Color lightSecondAccentColor = Color(0xffd9558a);
  static Color darkSecondAccentColor = Color(0xfff26f99);
  static Color darkPositiveGreenColor = Color.fromRGBO(3, 252, 119, 1.0);
  static Color lightPositiveGreenColor = Color(0xff29b369);
  static Color errorColorLight = Color.fromRGBO(230, 48, 75, 1.0);
  static Color errorColorDark = Color.fromRGBO(227, 57, 82, 1.0);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    accentColor: AppThemes.lightAccentColor,
    backgroundColor: Color(0xfff3f4f9),
    scaffoldBackgroundColor: Color(0xfff3f4f9),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textSelectionHandleColor: getAccentColor(),
    fontFamily: 'Varela',
    dividerColor: Colors.black12,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    accentColor: AppThemes.darkAccentColor,
    backgroundColor: Color(0xff27272b),
    scaffoldBackgroundColor: Color(0xff27272b),
    textSelectionHandleColor: getAccentColor(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: 'Varela',
    dividerColor: Colors.white10,
  );

  static Color getErrorColor() {
    return _context.isLightTheme ? errorColorLight : errorColorDark;
  }

  static Color getPositiveGreenColor() {
    return _context.isLightTheme ? lightPositiveGreenColor : darkPositiveGreenColor;
  }

  static Color getStartColor() {
    return  _context.isLightTheme ? lightStartColor : darkStartColor;
  }

  static Color getAccentColor() {
    return  _context.isLightTheme ? lightAccentColor : darkAccentColor;
  }

  static Color getSecondAccentColor() {
    return  _context.isLightTheme ? lightSecondAccentColor : darkSecondAccentColor;
  }
}

extension BandoColorScheme on ColorScheme {
  Color get success => brightness == Brightness.light ? Color(0xff29b369) : Color.fromRGBO(3, 252, 119, 1.0);
  Color get failure => brightness == Brightness.light ? Color.fromRGBO(230, 48, 75, 1.0) : Color.fromRGBO(227, 57, 82, 1.0);
  Color get first => brightness == Brightness.light ? Color(0xff5f74de) : Color(0xff677deb);
  Color get second => brightness == Brightness.light ? Color(0xff925bde) : Color(0xffa571f0);
  Color get accent => brightness == Brightness.light ? Color(0xffd9558a) : Color(0xfff26f99);
}
