import 'package:bando/models/file_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';

class LyricsPage extends StatefulWidget {
  final FileModel fileModel;

  LyricsPage({@required this.fileModel});

  @override
  State<StatefulWidget> createState() {
    return LyricsPageState();
  }
}

class LyricsPageState extends State<LyricsPage> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 600), () {
      updateStatusbarAndNavBar(context);
    });

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: PdfViewer(
              filePath: widget.fileModel.fileSystemEntity.path,
            ),
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              height: 105,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.black38, Colors.black12, Colors.transparent]
                )
              ),
              child: Padding(
                padding: const EdgeInsets.only(left : 35.0, top: 55),
                child: Text(
                  "${widget.fileModel.fileName()}",
                  style: TextStyle(color: Colors.black, fontSize: 24.0),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future updateStatusbarAndNavBar(BuildContext context) async {
    await FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    await FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
    await FlutterStatusbarcolor.setNavigationBarColor(Colors.black12);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(systemNavigationBarIconBrightness: Brightness.dark));

    return;
  }
}
