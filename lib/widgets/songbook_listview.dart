
import 'package:bando/models/file_model.dart';
import 'package:bando/widgets/file_item_widget.dart';
import 'package:flutter/cupertino.dart';

class SongbookListView extends StatefulWidget {
  final List<FileModel> songbook;
  final Function onItemClick;
  final Function onItemLongClick;
  final Color customColor;

  SongbookListView({Key key, @required this.songbook, @required this.onItemClick, @required this.onItemLongClick, this.customColor}) : super(key : key);

  @override
  State<StatefulWidget> createState() {
    return SongbookListViewState();
  }
}

class SongbookListViewState extends State<SongbookListView> {

  List<FileModel> files;

  @override
  void initState() {
    super.initState();
    files = List.from(widget.songbook);
  }

  void updateList(List<FileModel> newList) {
    files = List.from(newList);
    setState(() {
    });
  }

  void clearSelections() {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: files.length,
        itemBuilder: (BuildContext context, int index) {
          return new EntryFileItem(
            files[index],
            context,
            onClick: widget.onItemClick,
            onLongClick: widget.onItemLongClick,
            customColor : widget.customColor,
          );
        });
  }

}
