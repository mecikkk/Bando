import 'file:///D:/Android/Bando/FlutterProject/bando/lib/models/file_model.dart';
import 'file:///D:/Android/Bando/FlutterProject/bando/lib/widgets/file_item_widget.dart';
import 'package:flutter/cupertino.dart';

class SongbookListView extends StatefulWidget {
  final List<FileModel> songbook;
  final Function onItemClick;

  SongbookListView({Key key, @required this.songbook, @required this.onItemClick}) : super(key : key);

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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: files.length,
        itemBuilder: (BuildContext context, int index) {
          return new EntryFileItem(
            files[index],
            context,
            onClick: widget.onItemClick,
            onLongClick: () {},
          );
        });
  }

}
