import 'dart:io';

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