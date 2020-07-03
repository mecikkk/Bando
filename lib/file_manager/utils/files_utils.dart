import 'dart:io';
import 'package:bando/file_manager/models/file_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class FilesUtils {
  static Future<List<Directory>> getStorageList() async {
    List<Directory> paths = await getExternalStorageDirectories();
    List<Directory> filteredPaths = List<Directory>();
    for (Directory dir in paths) {
      filteredPaths.add(removeDataDirectory(dir.path));
    }
    return filteredPaths;
  }

  static Directory removeDataDirectory(String path) {
    return Directory(path.split("Android")[0]);
  }


  static Future<List<FileModel>> getFilesInPath(String path) async {
    Directory dir = Directory(path);
    List<FileModel> files = List<FileModel>();
    List<FileSystemEntity> allFiles = sortList(dir.listSync());

    if (allFiles.isNotEmpty) {
      allFiles.forEach((element) async {

        var children = List<FileModel>();
        var isDirectory = FileSystemEntity.isDirectorySync(element.path);

        if(isDirectory) {
          children = await getFilesInPath(element.path);
        }
        files.add(FileModel(element, children, isDirectory));

      });
    }

    return files;
  }

  static List<FileSystemEntity> sortList(List<FileSystemEntity> list){
    if (list.toString().contains("Directory")) {
      list
        ..sort((f1, f2) => basename(f1.path)
            .toLowerCase()
            .compareTo(basename(f2.path).toLowerCase()));
      return list
        ..sort((f1, f2) => f1
            .toString()
            .split(":")[0]
            .toLowerCase()
            .compareTo(f2.toString().split(":")[0].toLowerCase()));
    } else {
      return list
        ..sort((f1, f2) => basename(f1.path)
            .toLowerCase()
            .compareTo(basename(f2.path).toLowerCase()));
    }
  }



}
