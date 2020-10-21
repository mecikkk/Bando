import 'package:bando/utils/app_themes.dart';
import 'package:bando/utils/validator.dart';
import 'package:bando/widgets/text_field.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExpandableEditPanel extends StatelessWidget {
  final Widget header;
  final TextEditingController controller;
  final String textFieldLabel;
  final IconData textFieldIcon;
  final Function onConfirmClick;
  final bool isPassword;

  ExpandableEditPanel(
      {Key key,
      @required this.header,
      @required this.controller,
      @required this.textFieldLabel,
      @required this.textFieldIcon,
      @required this.onConfirmClick})
      : isPassword = false,
        super(key: key);

  ExpandableEditPanel.password(
      {Key key,
      @required this.header,
      @required this.controller,
      @required this.textFieldLabel,
      @required this.textFieldIcon,
      @required this.onConfirmClick})
      : isPassword = true,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpandablePanel(
      theme: ExpandableThemeData(
        expandIcon: Icons.edit,
        collapseIcon: Icons.close,
        iconColor: Theme.of(context).textTheme.bodyText1.color,
      ),
      header: Padding(padding: const EdgeInsets.only(top: 12.0), child: header),
      expanded: Container(
        height: 130.0,
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 9,
                      child: RoundedTextField(
                        controller: controller,
                        icon: textFieldIcon,
                        isValid: true,
                        labelText: textFieldLabel,
                        validator: (_) {
                          if(isPassword && controller.text.isNotEmpty) {
                            return Validators.isValidPassword(controller.text) ? null : "Min. 8 znaków (litery i cyfry)";
                          } else if (isPassword && controller.text.isNotEmpty) {
                            return Validators.isValidUsername(
                                controller.text)
                                ? null
                                : "Pole nie może być puste";
                          }
                          return null;
                        },
                        obscureText: isPassword,
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: Container(
                          height: 45.0,
                          width: 45.0,
                          decoration: BoxDecoration(
                            color: AppThemes.getPositiveGreenColor(context),
                            borderRadius: BorderRadius.all(Radius.circular(35.0)),
                            border: Border.all(color: AppThemes.getPositiveGreenColor(context)),
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.black,
                          ),
                        ),
                        onTap: onConfirmClick,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 24.0,
                thickness: 1.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
