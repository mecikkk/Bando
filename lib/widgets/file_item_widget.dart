import 'package:bando/models/file_model.dart';
import 'package:bando/utils/app_themes.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path/path.dart';

class EntryFileItem extends StatefulWidget {
  final FileModel _fileModel;
  final BuildContext context;
  final Function onLongClick;
  final Function onClick;
  final Color customColor;
  Map<String, bool> selections = Map();

  EntryFileItem(this._fileModel, this.context, {this.onClick, this.onLongClick, this.customColor, Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EntryFileItemState();
  }
}

class EntryFileItemState extends State<EntryFileItem> {
  BuildContext _context;

  @override
  void initState() {
    super.initState();
    widget.selections[widget._fileModel.fileSystemEntity.path] = false;
    if (widget._fileModel.children.isNotEmpty) {
      _setSelections(widget._fileModel);
    }
  }

  _setSelections(FileModel fileModel) {
    fileModel.children.forEach((element) {
      widget.selections[element.fileSystemEntity.path] = false;
      if (element.children.isNotEmpty) _setSelections(element);
    });
  }

  @override
  Widget build(BuildContext context) {
    _context = context;

    widget.selections.forEach((key, value) {
      debugPrint("SELECTION ($key , $value)");
    });

    if (widget.selections.isEmpty) {
      widget.selections[widget._fileModel.fileSystemEntity.path] = false;
      if (widget._fileModel.children.isNotEmpty) {
        _setSelections(widget._fileModel);
      }
    }
    return Padding(padding: const EdgeInsets.all(8.0), child: _buildTiles(widget._fileModel));
  }

  Widget _buildTiles(FileModel root) {
    return GestureDetector(
        onLongPress: () {
          print("selected : ${root.fileSystemEntity.path}");
          setState(() {
            widget.selections[root.fileSystemEntity.path] = !widget.selections[root.fileSystemEntity.path];
          });
          widget.onLongClick(root, widget.selections[root.fileSystemEntity.path]);
        },
        onTap: () {
          widget.onClick(root);
        },
        child: Container(
          decoration: widget.selections.isNotEmpty
              ? BoxDecoration(
                  color: widget.selections[root.fileSystemEntity.path]
                      ? AppThemes.getSecondAccentColor(widget.context).withOpacity(0.3)
                      : Colors.transparent,
                )
              : BoxDecoration(),
          child: root.children.isEmpty ? _fileOrEmptyDirectoryWidget(root) : _directoryWidget(root),
        ));
  }

  bool isTextFile(FileModel root) {
    return (extension(root.fileSystemEntity.path) == '.pdf');
  }

  Widget _fileOrEmptyDirectoryWidget(FileModel root) => Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: FileListTile(
        key: Key(root.localPath),
        svgAsset: root.isDirectory ? _getDirectoryIcon() : _getLyricsPageIcon(),
        fileName: root.fileName(),
        customColor: widget.customColor,
      ));

  Widget _directoryWidget(FileModel root) => Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: FileListExpandableTile(
          key: Key(root.localPath),
          svgAsset: root.isDirectory ? _getDirectoryIcon() : _getLyricsPageIcon(),
          file: root,
          children: root.children.map(_buildTiles).toList(),
          customColor: widget.customColor,
        ),
      );

  String _getDirectoryIcon() => (widget.customColor == null)
      ? (Theme.of(_context).brightness == Brightness.light) ? 'assets/folder_light.svg' : 'assets/folder.svg'
      : (widget.customColor == Colors.white) ? 'assets/folder.svg' : 'assets/folder_light.svg';

  String _getLyricsPageIcon() => (widget.customColor == null)
      ? (Theme.of(_context).brightness == Brightness.light) ? 'assets/audio-doc_light.svg' : 'assets/audio-doc.svg'
      : (widget.customColor == Colors.white) ? 'assets/audio-doc.svg' : 'assets/audio-doc_light.svg';
}

class FileListTile extends StatelessWidget {
  final String svgAsset;
  final String fileName;
  final Color customColor;

  FileListTile({Key key, @required this.svgAsset, @required this.fileName, this.customColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              svgAsset,
              width: 35.0,
              height: 35.0,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                fileName,
                overflow: TextOverflow.fade,
                style: TextStyle(
                    fontSize: 17.0,
                    color: (customColor == null) ? Theme.of(context).textTheme.bodyText1.color : customColor),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class FileListExpandableTile extends StatelessWidget {
  final String svgAsset;
  final FileModel file;
  final List<Widget> children;
  final Color customColor;

  FileListExpandableTile(
      {Key key, @required this.svgAsset, @required this.file, @required this.children, this.customColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ExpandablePanel(
          iconColor:
              (customColor == null) ? (AppThemes.isLightTheme(context) ? Colors.black45 : Colors.white) : customColor,
          header: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  svgAsset,
                  width: 35.0,
                  height: 35.0,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    file.fileName(),
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                        fontSize: 17.0,
                        color: (customColor == null) ? Theme.of(context).textTheme.bodyText1.color : customColor),
                  ),
                ),
              )
            ],
          ),
          expanded: Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          )),
    );
  }
}
