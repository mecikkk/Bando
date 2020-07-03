
import 'dart:ui';

import 'package:flutter/material.dart';

class Constants {
  static Color lightAccentColor = Color.fromRGBO(106, 61, 255, 1.0);
  static Color darkAccentColor = Color.fromRGBO(143, 110, 255, 1.0);
  static Color lightSecondAccentColor = Color.fromRGBO(189, 51, 86, 1.0);
  static Color darkSecondAccentColor = Color.fromRGBO(201, 73, 88, 1.0);



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