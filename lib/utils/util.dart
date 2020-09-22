import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

import 'app_themes.dart';

enum ConfigurationType {NEW_GROUP, JOIN_TO_EXIST}

enum GroupConfigurationType {CREATING_GROUP, JOINING_TO_GROUP}

extension FileSystemEntityExtention on FileSystemEntity{
  String get name {
    String withExt = this?.path?.split(Platform.pathSeparator)?.last;
    return withExt.replaceAll('.pdf', '');
  }
}

extension FileExtention on File{
  String get name {
    return this?.path?.split(Platform.pathSeparator)?.last;
  }
}

Future updateStatusbarAndNavBar(BuildContext context, {bool showWhiteStatusBarIcons = true}) async {
  await FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
  await FlutterStatusbarcolor.setStatusBarWhiteForeground(showWhiteStatusBarIcons);
  await FlutterStatusbarcolor.setNavigationBarColor(Theme.of(context).scaffoldBackgroundColor);
  await  FlutterStatusbarcolor.setNavigationBarWhiteForeground(!AppThemes.isLightTheme(context));

  return;
}