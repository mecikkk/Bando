
import 'dart:io';

import 'package:bando/file_manager/utils/files_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  test('Should show storage list', () async {

    List<Directory> allDirectories = await FilesUtils.getStorageList();

    print("Directories list : ");
    allDirectories.forEach((element) {
      print(element.path);
    });

  });

}