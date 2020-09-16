import 'package:bando/models/database_lyrics_file_info_model.dart';
import 'package:bando/models/deleted_files_model.dart';
import 'package:bando/models/file_model.dart';
import 'package:bando/utils/app_themes.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum SongbookUpdateType { NEW_CLOUD_FILES, NEW_LOCAL_FILES, NEW_LOCAL_CLOUD_FILES, DELETED_FILES }

class UpdateSongbookBottomSheet extends StatefulWidget {
  final String title;
  final String message;
  final List<FileModel> newLocalFiles;
  final List<DatabaseLyricsFileInfo> newCloudFiles;
  final List<DeletedFiles> deletedCloudFiles;
  final SongbookUpdateType updateType;
  final Function onCancelClick;
  final Function onUpdateClick;

  UpdateSongbookBottomSheet(
      {@required this.title,
      @required this.message,
      @required this.updateType,
      @required this.onCancelClick,
      @required this.onUpdateClick,
      this.newLocalFiles,
      this.newCloudFiles,
      this.deletedCloudFiles,
      Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UpdateSongbookBottomSheetState();
  }
}

class UpdateSongbookBottomSheetState extends State<UpdateSongbookBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 35, right: 35, top: 20, bottom: 20),
        height: MediaQuery.of(context).size.height / 1.5,
        child: Stack(children: <Widget>[
          Positioned(
            bottom: 0,
            right: 0,
            child: Opacity(
              opacity: 0.07,
              child: SvgPicture.asset(
                "assets/upload_download.svg",
                height: 250,
                width: 250,
              ),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(fontSize: 24.0),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.cancel,
                        color: Colors.redAccent,
                      ),
                      onPressed: widget.onCancelClick,
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
                  child: Text(
                    (widget.updateType == SongbookUpdateType.DELETED_FILES) ? "Usunięto pliki z grupowej bazy danych w chmurze. Czy chcesz zaktualizować pliki na urządzeniu ?": widget.message,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                Divider(
                  height: 24,
                  thickness: 1,
                  color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.3),
                ),
              ],
            ),
          ),
          Positioned(
            top: 155,
            bottom: 0,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailsWidget(widget.updateType),
                  (widget.deletedCloudFiles.isNotEmpty) ? _buildDeletedFilesExpandableView() : SizedBox(),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Spacer(),
                        FlatButton(
                          child: Text(
                            "AKTUALIZUJ".toUpperCase(),
                            style: TextStyle(color: AppThemes.getStartColor(context), fontSize: 16.0),
                          ),
                          onPressed: widget.onUpdateClick,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              side: BorderSide(color: AppThemes.getStartColor(context))),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ]));
  }

  Widget _buildDetailsWidget(SongbookUpdateType updateType) {
    switch (updateType) {
      case SongbookUpdateType.NEW_LOCAL_CLOUD_FILES:
        return Column(
          children: [
            _buildNewFilesExpandableView(widget.newCloudFiles, "Nowe pliki w chmurze", "assets/download.svg"),
            _buildNewFilesExpandableView(widget.newLocalFiles, "Nowe pliki na urządzeniu", "assets/local_storage.svg"),
          ],
        );
        break;
      case SongbookUpdateType.NEW_LOCAL_FILES:
        return _buildNewFilesExpandableView(
            widget.newLocalFiles, "Nowe pliki na urządzeniu", "assets/local_storage.svg");
        break;
      case SongbookUpdateType.NEW_CLOUD_FILES:
        return _buildNewFilesExpandableView(widget.newCloudFiles, "Nowe pliki w chmurze", "assets/download.svg");
        break;
      case SongbookUpdateType.DELETED_FILES:

      default:
        return SizedBox();
    }
  }

  Widget _buildNewFilesExpandableView(List<dynamic> files, String message, String iconAssetPath) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16.0),
        child: ExpandablePanel(
          iconColor: Theme.of(context).textTheme.bodyText1.color,
          header: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgPicture.asset(
                iconAssetPath,
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("$message (${files.length})"),
                ),
              ),
            ],
          ),
          expanded: Container(
            height: (25 * files.length).toDouble() + 25,
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0, left: 16.0, right: 16.0),
                child: Text(
                  "✓ ${files[index].localPath}",
                  style: TextStyle(fontSize: 16.0, color: AppThemes.getPositiveGreenColor(context)),
                ),
              ),
              itemCount: files.length,
            ),
          ),
        ),
      );

  Widget _buildDeletedFilesExpandableView() {

    List<Map<String, String>> deletedFiles = List();

    widget.deletedCloudFiles.forEach((details) {
      details.files.forEach((file) {
        deletedFiles.add({
          'name' : file['name'],
          'whoDeleted' : details.whoDeleted
        });
      });
    });

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16.0),
      child: Column(
        children: [
          ExpandablePanel(
            iconColor: Theme.of(context).textTheme.bodyText1.color,
            header: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/audio-doc_deleted.svg',
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Usunięte teksty i/lub foldery (${deletedFiles.length})"),
                  ),
                ),
              ],
            ),
            expanded: Container(
              height: (50 * deletedFiles.length).toDouble() + 25,
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0, left: 16.0, right: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "✖  ${deletedFiles[index]['name']}",
                        style: TextStyle(color: Colors.redAccent, fontSize: 15.0),
                      ),
                      Text(
                        "      Usunięte przez członka grupy - ${deletedFiles[index]['whoDeleted']} ",
                        style: TextStyle(color: Colors.redAccent.withOpacity(0.5), fontSize: 13.0),
                      ),
                    ],
                  ),
                ),
                itemCount: deletedFiles.length,
              ),
            ),
          ),
        ],
      )
    );
  }
}
