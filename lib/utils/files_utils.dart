import 'dart:io';

import 'package:bando/models/file_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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

  static Future<List<FileModel>> getBandoSongbookFiles() async {
    Directory songbookDirectory = await FilesUtils.getSongbookDirectory();

    return await FilesUtils.getFilesInPath(songbookDirectory.path);
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
        // Accept only directories and pdf files
        if(isPdfFile(element) || isDirectory)
          files.add(FileModel(element, children, isDirectory));

      });
    }

    return files;
  }

  static bool isPdfFile(FileSystemEntity root) {
    return (extension(root.path) == '.pdf');
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

  static Future<File> moveFile(File sourceFile, String newPath) async {
    try {
      print("Moving | source : ${sourceFile.path} | newPath : ${newPath}");
      return await sourceFile.rename("$newPath/${basename(sourceFile.path)}");
    } on FileSystemException catch (_) {
      final newFile = await sourceFile.copy(newPath);
      await sourceFile.delete();
      return newFile;
    }
  }

  static Future<int> deleteFile({String fullPath}) async {

    try {

      var file;

      file = File("$fullPath");

      debugPrint("Deleting file : ${file?.path}");

      file.deleteSync(recursive: true);

      return 1;

    } catch (e) {
      debugPrint("-- FileUtils | Deleting file error : $e");
      return -1;
    }

  }

  static String getFirestoreReferenceFromFileModel(FileModel fileModel) {
    String path = fileModel.fileSystemEntity.path;
    return path.substring(path.indexOf('BandoSongbook') + 14);
  }

  static String getSongbookFilePath(String path) {
    return path.substring(path.indexOf('BandoSongbook') + 14);
  }

  static Future<bool> moveSelectedDirToBandoDir(String selectedDirPath, {Directory destinationDir}) async {
    try {
      List<Directory> listOfStorages = await getStorageList();
      Directory appDir;

      if(destinationDir == null)
        appDir = Directory("${listOfStorages[0].path}/BandoSongbook");
      else
        appDir = destinationDir;

      List<FileSystemEntity> selectedDirFiles = Directory(selectedDirPath).listSync();
      selectedDirFiles.forEach((element) async {
        var isDirectory = FileSystemEntity.isDirectorySync(element.path);
        if(isDirectory) {
          Directory newDir = await createDirInBandoDirectory(basename(element.path));
          await moveSelectedDirToBandoDir(element.path, destinationDir: newDir);
        } else {
          moveFile(element, "${appDir.path}");
        }

      });

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }


  static Future<Directory> generateBandoSongbookDirectory() async {
    try {
      List<Directory> listOfStorages = await getStorageList();
      if(!Directory('${listOfStorages[0].path}/BandoSongbook').existsSync())
        return await new Directory('${listOfStorages[0].path}/BandoSongbook').create(recursive: false);
      else
        return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<Directory> getSongbookDirectory() async {
    try {
      List<Directory> listOfStorages = await getStorageList();
      return Directory('${listOfStorages[0].path}/BandoSongbook');
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<Directory> createDirInBandoDirectory(String dirName) async {
    try {
      List<Directory> listOfStorages = await getStorageList();
      return await new Directory('${listOfStorages[0].path}/BandoSongbook/$dirName').create(recursive: false);
    } catch (e) {
      print(e);
      return null;
    }
  }

}