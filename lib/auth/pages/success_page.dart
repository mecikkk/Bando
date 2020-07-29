import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';

import 'package:bando/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:bando/auth/models/group_model.dart';
import 'package:bando/file_manager/utils/files_utils.dart';
import 'package:bando/utils/consts.dart';
import 'package:bando/utils/util.dart';
import 'package:bando/widgets/rounded_colored_shadow_button.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';

//import 'package:share/share.dart';
//import 'package:qr_flutter/qr_flutter.dart';

class SuccessPage extends StatefulWidget {
  final ConfigurationType configurationType;
  final Group group;

  SuccessPage({@required this.configurationType, @required this.group});

  @override
  State<StatefulWidget> createState() {
    return SuccessPageState();
  }
}

class SuccessPageState extends State<SuccessPage> {

  GlobalKey globalKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Constants.updateNavBarTheme(context);

    return Scaffold(
        body: (widget.configurationType == ConfigurationType.NEW_GROUP) ? _newGroupContent() : _joinToGroupContent());
  }

  Future<void> _shareQRCode() async {
    try {
      RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      await Share.file(
          'esys image', 'qr_${widget.group.name.toLowerCase()}.jpg', pngBytes.buffer.asUint8List(), 'image/jpg',
          text: 'QR Grupy ${widget.group.name}');
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

  _joinToGroupContent() {
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
          SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.only(left : 20.0, top : 20.0, right : 20.0),
            child: Text(
              "Gratulujemy dołączenia do grupy ${widget.group.name} !",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: SvgPicture.asset(
              "assets/band.svg",
              height: 220,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left : 20.0, right : 20.0),
            child: Text(
              "Zaktualizuj swoją bibliotekę tekstów, lub dodaj własne i ciesz się z możliwości, jakie daje Bando :)",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.0, color: Colors.white),
            ),
          ),
          SizedBox(height: 40),
          Row(
            children: <Widget>[
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: RoundedColoredShadowButton(
                      onTap: () {
                        _onGoToAppClick();
                      },
                      text : "Przejdź do aplikacji",
                    width: 270,
                    height: 40,
                    iconSize: 25,
                    fontSize: 16,
                    icon: Icons.check,
                    textColor: Constants.positiveGreenColor,
                    shadowColor: Colors.transparent,
                    borderColor: Constants.positiveGreenColor,
                    iconColor: Constants.positiveGreenColor,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }


  _newGroupContent() {
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
              "Grupa ${widget.group.name}",
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
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(widget.group.name, style: TextStyle(fontSize: 14, color: Colors.black)),
                    ),
                    QrImage(
                      data: widget.group.groupId,
                      size: 180,
                    ),
                  ],
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
                        _onGoToAppClick();
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

  void _onGoToAppClick() {
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }
}
