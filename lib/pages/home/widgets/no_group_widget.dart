import 'package:bando/utils/app_themes.dart';
import 'package:bando/widgets/gradient_raised_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NoGroupWidget extends StatelessWidget {

  final Function onConfigureGroupClick;

  NoGroupWidget({@required this.onConfigureGroupClick});

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: UniqueKey(),
      padding: const EdgeInsets.only(top: 60.0),
      child: Align(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 5),
              child: Text(
                "Nie należysz do żadnej grupy",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 15, right: 20, left: 20),
              child: Text(
                "Utwórz nową grupę, lub dołącz do istniejącej",
                style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.7)),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: Lottie.asset(
                "assets/no_group_animation.json",
                repeat: true,
                width: 150,
                height: 150,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: GradientRaisedButton(
                text: "Grupa",
                height: 40,
                width: 200.0,
                colors: [AppThemes.getStartColor(context), AppThemes.getSecondAccentColor(context), AppThemes.getSecondAccentColor(context)],
                onPressed: onConfigureGroupClick,
              ),
            )
          ],
        ),
      ),
    );
  }

}