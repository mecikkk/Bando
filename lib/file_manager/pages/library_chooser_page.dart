import 'package:bando/file_manager/models/file_model.dart';
import 'package:bando/file_manager/utils/files_utils.dart';
import 'package:bando/file_manager/widgets/file_item_widget.dart';
import 'package:bando/utils/consts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';

class LibraryChooser extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LibraryChooserState();
  }
}

class LibraryChooserState extends State<LibraryChooser> {
  List<FileModel> files = List<FileModel>();
  FileModel selectedFileModel;

  @override
  void initState() {
    print("Start InitState");
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () => {getStoragePermission()});
  }

  getStoragePermission() async {
    print("Getting permission");

    Permission.storage.status.then((value) {
      if (!value.isGranted)  {
        Permission.storage.request().then((value) async {
          if (value.isGranted) {
            await loadFilesList();
          }
        });
      } else loadFilesList();

    });

  }

  loadFilesList() async {
    print("Start Loading All Files");
    var allStorage = await FilesUtils.getStorageList();
    print("Got storage list");
    FilesUtils.getFilesInPath(allStorage[0].path).then((value) {
      print("getting files ended");
      files = value;
      setState(() {
        print("Update UI");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Build all page");

    Constants.updateNavBarTheme(context);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          files.isEmpty ?
            Positioned(
                top: 200,
                width: MediaQuery.of(context).size.width,
                bottom: 0,
                child: Align(
                  alignment: Alignment.center,
                    child: CircularProgressIndicator()
                )
            ) :
            Positioned(
              top: 200,
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildFileManagerList(),
            ),
          Positioned(
            top: 20,
            child: _buildHeader(),
          ),
        ],
      ),
    );
  }



  Widget _buildFileManagerList() {
    return Container(
      child: ListView.builder(
          itemCount: files.length,
          itemBuilder: (BuildContext context, int index) {
            return new EntryFileItem(files[index], context, onLongClick : (file) {
              _showConfirmDialog(file);
            },
            onClick: (_) {},);
          }),
    );
  }

  Widget _buildHeader() {
    print("building header");
    return Container(
      height: 200,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).scaffoldBackgroundColor,
            spreadRadius: 0,
            blurRadius: 15,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 4.0, top: 50, left: 20, right: 20),
            child: Text(
              "Biblioteka",
              style: TextStyle(fontSize: 38.0, letterSpacing: 0),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 28.0, left: 23, right: 20),
            child: Text(
              "Znajdź i przytrzymaj folder z tekstami piosenek. Folder zostanie umieszczony w chmurze, aby reszta grupy mogła go pobrać.",
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showConfirmDialog(FileModel fileModel) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right : 8.0, bottom: 2.0),
                child: SvgPicture.asset("assets/folder.svg", height: 26, color: Theme.of(context).textTheme.bodyText1.color,),
              ),
              Text(
                '${fileModel.getFileName()}',
                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyText1.color,),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Pamiętaj, że folder musi zawierać pliki PDF z tekstami piosenek, z których będzie korzystać cała grupa.\n\nPotwierdź wybrany folder.',
                  style: TextStyle(fontSize: 14.0),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('ANULUJ'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                _selectDir(fileModel);
                Navigator.pop(context, fileModel);
              },
            ),
          ],
        );
      },
    );
  }

  void _selectDir(FileModel fileModel) {
    selectedFileModel = fileModel;
    Navigator.pop(context, selectedFileModel);
  }
}
