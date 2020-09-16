import 'package:bando/utils/app_themes.dart';
import 'package:bando/widgets/animated_opaticy_widget.dart';
import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StatusInfoWidget extends StatefulWidget {

  final dynamic opacityAnimation;
  final Function onUpdatePressed;

  StatusInfoWidget({this.opacityAnimation, this.onUpdatePressed, key}) : super(key : key);

  @override
  State<StatefulWidget> createState() {
    return StatusInfoWidgetState();
  }
}

class StatusInfoWidgetState extends State<StatusInfoWidget> {

  bool isSongbookActual = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacityWidget(
      opacity: widget.opacityAnimation,
      child: GestureDetector(
        onTap: widget.onUpdatePressed,
        child: ConnectivityWidget(
          showOfflineBanner: false,
          builder: (context, isOnline) {
            return isOnline ? Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left : 8.0, right: 8.0),
                  child: Icon(
                    isSongbookActual ? Icons.check_circle : Icons.error,
                    color: isSongbookActual ? AppThemes.getPositiveGreenColor(context).withOpacity(0.8) : Colors.orangeAccent,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left : 8.0, right: 8.0),
                  child: Text(
                    isSongbookActual ? "Pliki aktualne" : "Potrzebna aktualizacja",
                    style: TextStyle(
                      color: isSongbookActual ? AppThemes.getPositiveGreenColor(context).withOpacity(0.8) : Colors.orangeAccent,
                    ),
                  ),
                ),
              ],
            ) : Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.portable_wifi_off,
                    color: Colors.grey,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Offline",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            )
            ;
          },
        ),
      ),
    );
  }

  updateInfoState({bool songbookActual}) {
    setState(() {
      isSongbookActual = songbookActual;
    });
  }


}