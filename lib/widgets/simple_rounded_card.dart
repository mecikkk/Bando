import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SimpleRoundedCard extends StatelessWidget {
  final String text;
  final EdgeInsets padding;

  SimpleRoundedCard({
    @required this.text,
    this.padding
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: 100,
      child: Center(
        child: Text(
          text.toUpperCase(),
          maxLines: 2,
          softWrap: true,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16.0,
              color: Colors.white
          ),
        ),
      ),
    );
  }

//  @override
//  Widget build(BuildContext context) {
//    return Padding(
//      padding: padding ?? EdgeInsets.all(8.0),
//      child: Material(
//        borderRadius: BorderRadius.circular(15),
//        color: backgroundColor,
//        child: InkWell(
//          borderRadius: BorderRadius.circular(15),
//          onTap: onClick,
//          child: Container(
//            height: 70,
//            width: 70,
//            child: Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: Center(
//                child: Text(
//                  text.toUpperCase(),
//                  maxLines: 2,
//                  softWrap: true,
//                  textAlign: TextAlign.center,
//                  style: TextStyle(
//                    fontSize: 16.0
//                  ),
//                ),
//              ),
//            ),
//          ),
//        ),
//      ),
//    );
//  }
}
