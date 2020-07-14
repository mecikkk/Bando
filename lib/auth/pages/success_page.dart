import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';

import 'package:bando/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:bando/file_manager/utils/files_utils.dart';
import 'package:bando/utils/consts.dart';
import 'package:bando/utils/util.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';

//import 'package:share/share.dart';
//import 'package:qr_flutter/qr_flutter.dart';

class SuccessPage extends StatefulWidget {
  final ConfigurationType configurationType;
  final String groupId;
  final String groupName;

  SuccessPage({@required this.configurationType, this.groupId = "", this.groupName});

  @override
  State<StatefulWidget> createState() {
    return SuccessPageState();
  }
}

class SuccessPageState extends State<SuccessPage> {
  static const double _topSectionHeight = 50.0;

  GlobalKey globalKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Constants.updateNavBarTheme(context);

    return Scaffold(body: _contentWidget());
  }

  Future<void> _shareQRCode() async {
    try {
      RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      await Share.file(
          'esys image', 'qr_${widget.groupName.toLowerCase()}.jpg', pngBytes.buffer.asUint8List(), 'image/jpg',
          text: 'QR Grupy ${widget.groupName}');
    } catch (e) {
      print(e.toString());
    }
  }

  getPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request().then((value) => {
            if (value.isGranted) {_shareQRCode()}
          });
    }

    if (status.isGranted) _shareQRCode();
  }

  _contentWidget() {
    return Container(
      decoration: BoxDecoration(gradient: Constants.getGradient(context, Alignment.centerLeft, Alignment.topRight)),
      child: ListView(
        padding: EdgeInsets.all(20),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 4.0, top: 50),
            child: Text(
              "Witamy w Bando !",
              style: TextStyle(fontSize: 38.0, letterSpacing: 0, color: Colors.white),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 28.0, left: 3),
            child: Text(
              "Grupa ${widget.groupName}",
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Poniższy kod QR pozwoli Ci dodać do grupy nowych członków. Wystarczy, że zeskanują kod, a aplikacja wszystkim się zajmie :)",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.0, color: Colors.white),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              color: Colors.white,
              child: RepaintBoundary(
                key: globalKey,
                child: QrImage(
                  data: widget.groupId,
                  size: 180,
                ),
              ),
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Pokaż użytkownikom kod, udostępnij go, lub odłóż na później dodawanie nowych osób do grupy.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.0, color: Colors.white),
            ),
          ),
          SizedBox(height: 40),
          Row(
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: FlatButton.icon(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25), side: BorderSide(color: Colors.white)),
                    onPressed: () {
                      getPermission();
                    },
                    icon: Icon(Icons.share),
                    label: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Udostępnij",
                        style: TextStyle(fontSize: 16),
                      ),
                    )),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FlatButton(
                      onPressed: () {
                        BlocProvider.of<AuthBloc>(context).add(AuthLoggedIn());

                        Future.delayed(Duration(seconds: 1), () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        });

                      },
                      child: Text(
                        "Zakończ".toUpperCase(),
                        style: TextStyle(fontSize: 16),
                      )),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
