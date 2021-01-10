import 'package:bando/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';

class RoundedTextField extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType inputType;
  final String labelText;
  final IconData icon;
  final bool obscureText;
  final FormFieldValidator<String> validator;

  RoundedTextField({
    Key key,
    this.controller,
    this.inputType,
    this.labelText,
    this.icon,
    this.obscureText = false,
    this.validator,
  }) : super(key: key);

  factory RoundedTextField.email({
    Key key,
    @required TextEditingController controller,
    @required String labelText,
    @required FormFieldValidator<String> validator,
  }) =>
      RoundedTextField(
        key: key,
        controller: controller,
        inputType: TextInputType.emailAddress,
        labelText: labelText,
        icon: Icons.email_outlined,
        obscureText: false,
        validator: validator,
      );

  factory RoundedTextField.password({
    Key key,
    @required TextEditingController controller,
    @required String labelText,
    @required FormFieldValidator<String> validator,
  }) =>
      RoundedTextField(
        key: key,
        controller: controller,
        inputType: TextInputType.visiblePassword,
        labelText: labelText,
        icon: Icons.lock_outline,
        obscureText: true,
        validator: validator,
      );

  factory RoundedTextField.custom({
    Key key,
    @required TextEditingController controller,
    @required String labelText,
    @required FormFieldValidator<String> validator,
    IconData icon,
    bool obscureText,
    TextInputType inputType,
  }) =>
      RoundedTextField(
        key: key,
        controller: controller,
        inputType: inputType,
        labelText: labelText,
        icon: icon,
        obscureText: obscureText,
        validator: validator,
      );

  @override
  State<StatefulWidget> createState() => RoundedTextFieldState();
}

class RoundedTextFieldState extends State<RoundedTextField> {
  FocusNode _focusNode = FocusNode();
  bool _isValid;
  bool _isPasswordVisible;

  @override
  void initState() {
    _focusNode.addListener(() {
      setState(() {});
    });
    _isValid = true;
    _isPasswordVisible = widget.obscureText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: _setDecoration(widget.inputType),
        keyboardType: widget.inputType,
        obscureText: _isPasswordVisible,
        cursorColor: context.colors.accent,
        autovalidateMode: AutovalidateMode.always,
        autocorrect: false,
        validator: widget.validator);
  }

  void updateValidState(bool isValid) {
    _isValid = isValid;
  }

  InputDecoration _setDecoration(TextInputType passwordDecoration) {
    return (passwordDecoration == TextInputType.visiblePassword)
        ? InputDecoration(
            border: buildOutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 10.0),
            focusedBorder: buildOutlineInputBorder(),
            prefixIcon: Icon(
              widget.icon,
              color: _isValid ? _setColor() : Colors.redAccent,
            ),
            labelText: widget.labelText,
            suffixIcon: GestureDetector(
              child: Icon(
                !_isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Theme.of(context).textTheme.bodyText1.color,
              ),
              onTap: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
                debugPrint("visibility : $_isPasswordVisible ");
              },
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            labelStyle: TextStyle(
              color: _setColor(),
            ))
        : InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 10.0),
            border: buildOutlineInputBorder(),
            focusedBorder: buildOutlineInputBorder(),
            prefixIcon: Icon(
              widget.icon,
              color: _isValid ? _setColor() : Colors.redAccent,
            ),
            labelText: widget.labelText,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            labelStyle: TextStyle(
              color: _setColor(),
            ));
  }

  OutlineInputBorder buildOutlineInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(35.0),
      borderSide: BorderSide(
        color: _setColor(),
      ),
    );
  }

  Color _setColor() => _focusNode.hasFocus ? _focusedColor() : _disabledColor();

  Color _focusedColor() => (Theme.of(context).brightness == Brightness.dark) ? Colors.white : Colors.black;

  Color _disabledColor() => (Theme.of(context).brightness == Brightness.dark) ? Colors.white60 : Colors.black54;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
