import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoundedTextField extends StatefulWidget {
  final TextEditingController controller;
  TextInputType inputType = TextInputType.visiblePassword;
  final String labelText;
  final IconData icon;
  final bool isValid;
  final bool passwordMode;
  final FormFieldValidator<String> validator;

  RoundedTextField({
    @required this.controller,
    this.inputType,
    @required this.labelText,
    @required this.icon,
    @required this.isValid,
    @required this.passwordMode,
    @required this.validator,
  });

  @override
  State<StatefulWidget> createState() => RoundedTextFieldState();
}

class RoundedTextFieldState extends State<RoundedTextField> {

  FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    _focusNode.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
            border: buildOutlineInputBorder(),
            focusedBorder: buildOutlineInputBorder(),
            prefixIcon: Icon(
              widget.icon,
              color: widget.isValid ? _setColor() : Colors.redAccent,
            ),
            labelText: widget.labelText,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            labelStyle: TextStyle(
              color: _setColor(),
            )),
        keyboardType: widget.inputType,
        obscureText: widget.passwordMode,
        autovalidate: true,
        autocorrect: false,
        validator: widget.validator);
  }

  OutlineInputBorder buildOutlineInputBorder() {
    return OutlineInputBorder(
              borderRadius: BorderRadius.circular(35.0),
              borderSide: BorderSide(
                color: _setColor(),
              ),
          );
  }

  Color _setColor() =>  _focusNode.hasFocus ? _focusedColor() : _disabledColor();

  Color _focusedColor() => (Theme.of(context).brightness == Brightness.dark) ? Colors.white : Colors.black;

  Color _disabledColor() => (Theme.of(context).brightness == Brightness.dark) ? Colors.white60 : Colors.black54;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
