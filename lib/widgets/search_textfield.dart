import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final Function onChanged;
  final Color searchBarOutlineFocusColor;

  SearchTextField({
    @required this.controller,
    @required this.labelText,
    @required this.onChanged,
    @required this.searchBarOutlineFocusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: TextFormField(
        controller: controller,
        decoration: _setDecoration(),
        keyboardType: TextInputType.text,
        style: TextStyle(color: searchBarOutlineFocusColor.withOpacity(0.8)),
        onChanged: onChanged,
        obscureText: false,
        autovalidate: true,
        autocorrect: false,
      ),
    );
  }

  InputDecoration _setDecoration() {
    return InputDecoration(
      border: buildOutlineInputBorder(),
      focusedBorder: buildOutlineInputBorder(),
      enabledBorder: buildOutlineInputBorder(),
      disabledBorder: buildOutlineInputBorder(),
      fillColor: Colors.black87,
      focusColor: Colors.black87,
      hoverColor: Colors.black87,
      labelText: labelText,
      contentPadding: EdgeInsets.only(bottom: 25, right: 10, left: 20),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      labelStyle: TextStyle(color: searchBarOutlineFocusColor.withOpacity(0.9)),
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