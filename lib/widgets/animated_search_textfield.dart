import 'package:bando/widgets/search_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedSearchTextField extends AnimatedWidget {
  final TextEditingController controller;
  final String labelText;
  final double maxWidth;
  final Function onChanged;
  final Color searchBarOutlineFocusColor;

  AnimatedSearchTextField({
    @required this.controller,
    @required this.maxWidth,
    @required this.labelText,
    @required this.onChanged,
    @required this.searchBarOutlineFocusColor,
    @required width,
  }) : super(listenable: width);

  Animation<double> get width => listenable;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (width.value * maxWidth),
      height: 50,
      child: Opacity(
        opacity: width.value,
        child: SearchTextField(
          controller: controller,
          labelText: labelText,
          onChanged: onChanged,
          searchBarOutlineFocusColor: searchBarOutlineFocusColor,
        ),
      ),
    );
  }
}
