import 'dart:io';

import 'package:bando/file_manager/models/file_model.dart';
import 'package:bando/home/pages/lyrics_page.dart';
import 'package:bando/utils/consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path/path.dart';

class EntryFileItem extends StatelessWidget {
  final FileModel _fileModel;
  final BuildContext context;
  final Function onLongClick;
  final Function onClick;

  EntryFileItem(this._fileModel, this.context, {this.onClick , this.onLongClick});

  Widget _buildTiles(FileModel root) {
    return GestureDetector(
        onLongPress: () {
          print("${root.fileSystemEntity.path}");
          if (root.isDirectory) {
            onLongClick(root);
          }
        },
        onTap: () {
          onClick(root);
        },
        child: root.children.isEmpty ? _fileOrEmptyDirectoryWidget(root) : _directoryWidget(root));
  }

  void _loadFile(File file) async {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return LyricsPage(path: file.path);
    }));
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
