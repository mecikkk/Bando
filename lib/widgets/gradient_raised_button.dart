import 'package:bando/utils/consts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GradientRaisedButton extends StatelessWidget {

  final double height;
  final List<Color> colors;
  final String text;
  final Function onPressed;

  GradientRaisedButton({
    @required this.text,
    @required this.height,
    @required this.colors,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) =>
      Container(
        height: height,
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
                  colors: [Constants.getSecondAccentColor(context), Constants.getAccentColor(context), Constants.getStartColor(context)]),
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