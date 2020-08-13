import 'package:bando/file_manager/models/file_model.dart';
import 'package:bando/utils/consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path/path.dart';

class EntryFileItem extends StatefulWidget {
  final FileModel _fileModel;
  final BuildContext context;
  final Function onLongClick;
  final Function onClick;
  Map<String, bool> selections = Map();

  EntryFileItem(this._fileModel, this.context, {this.onClick, this.onLongClick});

  @override
  State<StatefulWidget> createState() {
    return EntryFileItemState();
  }
}

class EntryFileItemState extends State<EntryFileItem> {

  @override
  void initState() {
    super.initState();
    widget.selections[widget._fileModel.fileSystemEntity.path] = false;
    if(widget._fileModel.children.isNotEmpty) {
      _setSelections(widget._fileModel);
    }
  }

  _setSelections(FileModel fileModel) {
    fileModel.children.forEach((element) {
      widget.selections[element.fileSystemEntity.path] = false;
      if(element.children.isNotEmpty)
        _setSelections(element);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(8.0), child: _buildTiles(widget._fileModel));
  }

  Widget _buildTiles(FileModel root) {
    return GestureDetector(
        onLongPress: () {
          print("selected : ${root.fileSystemEntity.path}");
          setState(() {
            widget.selections[root.fileSystemEntity.path] = !widget.selections[root.fileSystemEntity.path];
          });
          widget.onLongClick(root);
        },
        onTap: () {
          widget.onClick(root);
        },
        child: Container(
          decoration: BoxDecoration(
            color: widget.selections[root.fileSystemEntity.path]
                ? Constants.getEndGradientColor(widget.context).withOpacity(0.3)
                : Colors.transparent,
          ),
          child: root.children.isEmpty ? _fileOrEmptyDirectoryWidget(root) : _directoryWidget(root),
        ));
  }

  bool isTextFile(FileModel root) {
    return (extension(root.fileSystemEntity.path) == '.pdf');
  }

  Widget _fileOrEmptyDirectoryWidget(FileModel root) => Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: ListTile(
          leading: SvgPicture.asset(
            root.isDirectory ? 'assets/folder.svg' : (isTextFile(root) ? 'assets/audio-doc.svg' : 'assets/doc.svg'),
            width: 35.0,
            height: 35.0,
          ),
          title: Text(root.getFileName()),
        ),
      );

  Widget _directoryWidget(FileModel root) => Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: ExpansionTile(
          key: PageStorageKey<FileModel>(root),
          leading: SvgPicture.asset(
            root.isDirectory ? 'assets/folder.svg' : (isTextFile(root) ? 'assets/audio-doc.svg' : 'assets/doc.svg'),
            width: 35.0,
            height: 35.0,
          ),
          title: Text(root.getFileName()),
          children: root.children.map(_buildTiles).toList(),
        ),
      );
}
/*

class EntryFileItem extends StatelessWidget {
  final FileModel _fileModel;
  final BuildContext context;
  final Function onLongClick;
  final Function onClick;
  bool isSelected = false;

  EntryFileItem(this._fileModel, this.context, {this.onClick, this.onLongClick});

  Widget _buildTiles(FileModel root) {
    return GestureDetector(
        onLongPress: () {
          print("selected : ${root.fileSystemEntity.path}");
//          if (root.isDirectory) {
          isSelected = !isSelected;
          onLongClick(root);
//          }
        },
        onTap: () {
          onClick(root);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Constants.getEndGradientColor(context).withOpacity(0.3) : Theme.of(context).scaffoldBackgroundColor,
          ),
          child: root.children.isEmpty ? _fileOrEmptyDirectoryWidget(root) : _directoryWidget(root),
        ));
  }

  bool isTextFile(FileModel root) {
    return (extension(root.fileSystemEntity.path) == '.pdf');
  }

  Widget _fileOrEmptyDirectoryWidget(FileModel root) => Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: ListTile(
          leading: SvgPicture.asset(
            root.isDirectory ? 'assets/folder.svg' : (isTextFile(root) ? 'assets/audio-doc.svg' : 'assets/doc.svg'),
            width: 35.0,
            height: 35.0,
          ),
          title: Text(root.getFileName()),
        ),
      );

  Widget _directoryWidget(FileModel root) => Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: ExpansionTile(
          key: PageStorageKey<FileModel>(root),
          leading: SvgPicture.asset(
            root.isDirectory ? 'assets/folder.svg' : (isTextFile(root) ? 'assets/audio-doc.svg' : 'assets/doc.svg'),
            width: 35.0,
            height: 35.0,
          ),
          title: Text(root.getFileName()),
          children: root.children.map(_buildTiles).toList(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(8.0), child: _buildTiles(_fileModel));
  }
}
*/
