import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

import 'app_themes.dart';

enum ConfigurationType {NEW_GROUP, JOIN_TO_EXIST}

enum GroupConfigurationType {CREATING_GROUP, JOINING_TO_GROUP}

extension FileSystemEntityExtention on FileSystemEntity{
  String get name {
    return this?.path?.split(Platform.pathSeparator)?.last;
  }
}

extension FileExtention on File{
  String get name {
    return this?.path?.split(Platform.pathSeparator)?.last;
  }
}

void updateStatusbarAndNavBar(BuildContext context, {bool showWhiteStatusBarIcons = true}) async {
  await FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
  FlutterStatusbarcolor.setStatusBarWhiteForeground(showWhiteStatusBarIcons);
  FlutterStatusbarcolor.setNavigationBarColor(Theme.of(context).scaffoldBackgroundColor);
  FlutterStatusbarcolor.setNavigationBarWhiteForeground(!AppThemes.isLightTheme(context));
}