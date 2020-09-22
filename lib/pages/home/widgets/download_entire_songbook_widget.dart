import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DownloadTheEntireSongbookWidget extends StatelessWidget {

  final Function onDownloadClick;

  DownloadTheEntireSongbookWidget({@required this.onDownloadClick});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Text(
            "Pobierz teksty",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 26.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0),
          child: Text(
            "Grupa posiada w chmurze bibliotekę z tekstami. Pobierz pliki na swoje urządzenie, aby móc korzystać z aplikacji offline.",
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.white70,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: RaisedButton(
                  onPressed: onDownloadClick,
                  child: Text(
                    "Pobierz".toUpperCase(),
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Theme.of(context).accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Text(
            "Pobrane pliki zostaną umieszczone w specjalnie utworzonym folderze \"BandoSongbook\".",
            style: TextStyle(fontSize: 14.0, color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.5)),
          ),
        ),
      ],
    );
  }



}