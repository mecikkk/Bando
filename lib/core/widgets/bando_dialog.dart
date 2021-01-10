import 'package:bando/core/utils/context_extensions.dart';
import 'package:bando/core/widgets/rounded_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class BandoDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final String confirmActionLabel;
  final String cancelActionLabel;
  final Function onConfirmClick;
  final Function onCancelClick;

  BandoDialog({
    @required this.title,
    @required this.content,
    @required this.confirmActionLabel,
    @required this.cancelActionLabel,
    this.onConfirmClick,
    this.onCancelClick,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: content,
      backgroundColor: context.bgColor,
      elevation: 25.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
      actions: [
        FlatButton(
          onPressed: () {
            if (onCancelClick != null) onCancelClick();
            Navigator.of(context).pop();
          },
          child: Text(
            cancelActionLabel.toUpperCase(),
            style: TextStyle(
              color: context.textColor,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right : 8.0),
          child: RoundedOutlinedButton(
            label: confirmActionLabel,
            onClick: () {
              if (onConfirmClick != null) onConfirmClick();
              Navigator.of(context).pop();
            },
            labelColor: context.colors.accent,
            borderColor: context.colors.accent,
          ),
        ),
      ],
    );
  }
}
