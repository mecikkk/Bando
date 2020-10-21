import 'package:bando/utils/app_themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogWidget extends StatelessWidget {

  final String title;
  final Widget content;
  final Function onAcceptClick;

  DialogWidget({@required this.title, @required this.content, @required this.onAcceptClick});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      title: Text("Nowy Nick"),
      content: content,
      actions: [
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            "ANULUJ",
            style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color),
          ),
        ),
        OutlineButton(
          borderSide: BorderSide(
            color: AppThemes.getStartColor(context),
          ),
          shape: StadiumBorder(),
          onPressed: () {
            onAcceptClick();
            Navigator.pop(context);
          },
          child: Text(
            " AKCEPTUJ ",
            style: TextStyle(color: AppThemes.getStartColor(context)),
          ),
        ),
      ],
    );
  }

}