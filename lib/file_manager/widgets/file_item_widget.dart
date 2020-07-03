
import 'package:bando/file_manager/models/file_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path/path.dart';

class EntryFileItem extends StatelessWidget {
  final FileModel _fileModel;

  EntryFileItem(this._fileModel);

  Widget _buildTiles(FileModel root) {
    return GestureDetector(
      onLongPress: () {
        if(root.isDirectory)
          debugPrint("Selected dir : ${root.getFileName()}");
      },
      child: root.children.isEmpty ? _fileOrEmptyDirectoryWidget(root) : _directoryWidget(root)
    );
  }

  bool isTextFile(FileModel root) {
    String fileExtension = extension(root.fileSystemEntity.path);
    List<String> extensions = ['.doc', '.docx', '.pdf', '.rtf'];

    for(int i = 0; i < extensions.length; i++){
      if(extensions[i] == fileExtension) return true;
    }

    return false;

  }

  Widget _fileOrEmptyDirectoryWidget(FileModel root) => Padding(
    padding: const EdgeInsets.only(left : 4.0),
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
    padding: const EdgeInsets.only(left : 4.0),
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _buildTiles(_fileModel)
    );
  }
}
