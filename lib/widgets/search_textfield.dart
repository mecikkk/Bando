import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchTextField extends AnimatedWidget {
  final TextEditingController controller;
  final String labelText;
  final double maxWidth;
  final Function onChanged;
  final Color searchBarOutlineFocusColor;

  SearchTextField({
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
        child: TextFormField(
          controller: controller,
          decoration: _setDecoration(),
          keyboardType: TextInputType.text,
          onChanged: onChanged,
          obscureText: false,
          autovalidate: true,
          autocorrect: false,
        ),
      ),
    );
  }

  InputDecoration _setDecoration() {
    return InputDecoration(
      border: buildOutlineInputBorder(),
      focusedBorder: buildOutlineInputBorder(),
      labelText: labelText,
      contentPadding: EdgeInsets.only(bottom: 25, right: 10, left: 20),
      floatingLabelBehavior: FloatingLabelBehavior.never,
    );
  }

  OutlineInputBorder buildOutlineInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(35.0),
      borderSide: BorderSide(
        color: searchBarOutlineFocusColor,
      ),
    );
  }
}
