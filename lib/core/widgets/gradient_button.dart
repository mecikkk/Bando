import 'package:bando/core/utils/app_theme.dart';
import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {

  final double height;
  final String text;
  final Function onPressed;
  final double width;

  GradientButton({
    @required this.text,
    @required this.height,
    @required this.onPressed,
    this.width = -1.0
  });

  @override
  Widget build(BuildContext context) =>
      Container(
        height: height,
        width: (width != -1.0)? width : MediaQuery.of(context).size.width,
        child: FlatButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  30.0)),
          onPressed: onPressed,
          padding: EdgeInsets.all(
              0.0),
          child: Ink(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                  radius: 7.5,
                  stops: [0.001, 0.4, 1.0],
                  center: Alignment.topRight,
                  colors: [AppThemes.getSecondAccentColor(context), AppThemes.getAccentColor(context), AppThemes.getStartColor(context)]),
              borderRadius: BorderRadius.circular(
                  30.0),

            ),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                text.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0
                ),
              ),
            ),
          ),
        ),
      );

}