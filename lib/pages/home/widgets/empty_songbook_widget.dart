import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptySongbookWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Text(
            "Śpiewnik jest pusty",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
          child: Text(
            "Na urządzeniu został utworzony nowy folder \"BandoSongbook\". Umieść w nim pliki PDF z tekstami. Pliki innego typu niż PDF będą pomijane.",
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 16.0,
              color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.7),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top : 20.0, bottom: 10.0),
          child: Center(
            child: Lottie.asset(
              "assets/empty_animation.json",
              repeat: true,
              width: 150,
              height: 150,
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(right: 20, left: 20, top : 20),
          child: Text(
            "Zawartość folderu zostanie umieszczona w chmurze i udostępniona wszystkim członkom grupy.",
            style: TextStyle(fontSize: 14.0, color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.5)),
          ),
        ),
      ],
    );
  }
}