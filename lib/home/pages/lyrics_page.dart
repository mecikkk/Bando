import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';

class LyricsPage extends StatelessWidget {
  final String path;

  LyricsPage({@required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top : 24),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: PdfViewer(
          filePath: path,
        ),
      ),
    );
  }
}
