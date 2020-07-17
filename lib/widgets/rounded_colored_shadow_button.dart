import 'package:bando/utils/consts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoundedColoredShadowButton extends StatelessWidget {

  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final Color backgroundColor;
  final Color shadowColor;
  final String text;
  final IconData icon;
  final Function onTap;
  final double height;
  final double width;
  final double iconSize;
  final double fontSize;

  RoundedColoredShadowButton({
    this.borderColor = Colors.grey,
    this.iconColor = Colors.grey,
    this.textColor = Colors.grey,
    this.backgroundColor = Colors.transparent,
    this.shadowColor = Colors.grey,
    this.iconSize = 30,
    this.fontSize = 18,
    @required this.height,
    @required this.width,
    @required this.text,
    @required this.icon,
    @required this.onTap,});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(
                70),
            border: Border.all(
                color: borderColor
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 15,
                spreadRadius: 1,
                offset: Offset(
                    0, 0),
              )
            ]
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon, color: iconColor, size: iconSize,),
            Padding(
              padding: const EdgeInsets.only(
                  left: 8, right: 8),
              child: Text(
                text.toUpperCase(
                ), style: TextStyle(
                  fontSize: fontSize, color: textColor),),
            )
          ],
        ),
      ),
    );
  }

}