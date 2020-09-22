import 'package:bando/utils/app_themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeHeaderWidget extends StatelessWidget {

  final String groupName;
  final String username;
  final Function onProfileClick;

  HomeHeaderWidget({@required this.groupName, @required this.username, @required this.onProfileClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          gradient: AppThemes.getGradient(context, Alignment.centerLeft, Alignment.topRight),
          boxShadow: [
            BoxShadow(
              color: (Theme.of(context).brightness == Brightness.light)
                  ? Colors.black.withOpacity(0.4)
                  : Colors.black.withOpacity(0.6),
              spreadRadius: 0,
              blurRadius: 15,
              offset: Offset(0, 1),
            ),
          ]),
      child: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0, left: 20.0),
                    child: Text(
                      groupName,
                      style: TextStyle(color: Colors.white, fontSize: 28.0),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onProfileClick,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0, right: 20.0),
                    child: Icon(Icons.account_circle, color: Colors.white),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 22.0),
              child: Text(
                "Witaj $username",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            SizedBox(height: 40),
            _buildSubtitle("Aktualny tekst"),
            _buildCurrentSongTitleWidget(
              context,
              "W Krainieckiej dziewczynie każdy się cieszy, jak jo dotyko",
              "śpiewnik/blok1",
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle(String text) {
    return Container(
      padding: EdgeInsets.only(left: 22.0, bottom: 8),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: TextStyle(color: Colors.white, fontSize: 14.0),
      ),
    );
  }

  Widget _buildCurrentSongTitleWidget(BuildContext context, String title, String directory) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: SvgPicture.asset(
              "assets/audio-doc.svg",
              height: 30,
              color: Colors.white,
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    // Song Title
                    title,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Icon(
                          Icons.folder_open,
                          color: Colors.white70,
                          size: 16,
                        ),
                      ),
                      Text(
                        // Directory name
                        directory,
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white70, fontSize: 14.0, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}