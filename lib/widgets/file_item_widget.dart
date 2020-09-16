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
  Map<String, bool> selections = Map();

  EntryFileItem(this._fileModel, this.context, {this.onClick, this.onLongClick, Key key}) : super(key: key);

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

  Widget _fileOrEmptyDirectoryWidget(FileModel root) => Container(
        width: MediaQuery.of(_context).size.width - 50,
        child: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: FileListTile(
              svgAsset: root.isDirectory ? _getDirectoryIcon() : _getLyricsPageIcon(),
              fileName: root.fileName(),
            )

            // ListTile(
            //   leading: SvgPicture.asset(
            //     root.isDirectory ? _getDirectoryIcon() : _getLyricsPageIcon(),
            //     width: 35.0,
            //     height: 35.0,
            //   ),
            //   title: Text(root.fileName()),
            // ),
            ),
      );

  Widget _directoryWidget(FileModel root) => Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: FileListExpandableTile(
            svgAsset: root.isDirectory ? _getDirectoryIcon() : _getLyricsPageIcon(),
            fileName: root.fileName(),
            children: root.children.map(_buildTiles).toList()),
      );

  String _getDirectoryIcon() =>
      (Theme.of(_context).brightness == Brightness.light) ? 'assets/folder_light.svg' : 'assets/folder.svg';

  String _getLyricsPageIcon() =>
      (Theme.of(_context).brightness == Brightness.light) ? 'assets/audio-doc_light.svg' : 'assets/audio-doc.svg';
}

class FileListTile extends StatelessWidget {
  final String svgAsset;
  final String fileName;

  FileListTile({@required this.svgAsset, @required this.fileName});

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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              fileName,
              style: TextStyle(fontSize: 17.0),
            ),
          )
        ],
      ),
    );
  }
}

class FileListExpandableTile extends StatelessWidget {
  final String svgAsset;
  final String fileName;
  final List<Widget> children;

  FileListExpandableTile({@required this.svgAsset, @required this.fileName, @required this.children, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ExpandablePanel(
        iconColor: AppThemes.isLightTheme(context) ? Colors.black45 : Colors.white,
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  fileName,
                  style: TextStyle(fontSize: 17.0),
                ),
              )
            ],
          ),
          expanded: Container(
            width: MediaQuery.of(context).size.width,
            height: (65.0 * (children.length)) + (2 * children.length),
            child: Column(
              children: children,
            ),
          )),
    );
  }
}
