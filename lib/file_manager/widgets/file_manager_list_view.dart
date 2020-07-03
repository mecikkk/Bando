import 'package:bando/file_manager/models/file_model.dart';
import 'package:bando/file_manager/utils/files_utils.dart';
import 'package:bando/file_manager/widgets/file_item_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class FileManagerListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FileManagerListViewState();
  }
}

class FileManagerListViewState extends State<FileManagerListView> {
  List<FileModel> files = List<FileModel>();

  @override
  void initState() {
    getPermission();

    super.initState();
  }

  getPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request().then((value) => {
            if (value.isGranted) {loadFilesList()}
          });
    }

    if (status.isGranted) loadFilesList();
  }

  void loadFilesList() async {
    var allStorages = await FilesUtils.getStorageList();
    files = await FilesUtils.getFilesInPath(allStorages[0].path);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
          color: Colors.white),
      child: Expanded(
        child: ListView.builder(
            itemCount: files.length,
            itemBuilder: (BuildContext context, int index) {
              return new EntryFileItem(files[index]);
            }),
      ),
    );
  }
}
