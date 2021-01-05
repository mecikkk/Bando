import 'package:bando/core/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:bando/core/utils/context_extensions.dart';

class RoundedOutlinedButton extends StatelessWidget {
  final String label;
  final Function onClick;
  final Widget icon;
  final Color labelColor;
  final Color borderColor;
  final Color rippleColor;
  final double labelSize;

  RoundedOutlinedButton({
    @required this.label,
    @required this.onClick,
    this.labelSize = 14.0,
    this.labelColor,
    this.borderColor,
    this.rippleColor,
  }) : icon = null;

  RoundedOutlinedButton.icon({
    @required this.label,
    @required this.onClick,
    @required this.icon,
    this.labelSize = 14.0,
    this.labelColor,
    this.borderColor,
    this.rippleColor,
  });

  @override
  Widget build(BuildContext context) => (icon == null)
      ? OutlinedButton(
          style: _getStyle(context),
          onPressed: onClick,
          child: _getLabel(context),
        )
      : OutlinedButton.icon(
          style: _getStyle(context),
          onPressed: onClick,
          icon: icon,
          label: _getLabel(context),
        );

  ButtonStyle _getStyle(BuildContext context) => OutlinedButton.styleFrom(
        primary: rippleColor ?? AppThemes.getSecondAccentColor(context),
        shape: StadiumBorder(),
        side: BorderSide(color: borderColor ?? context.textColor),
      );

  Text _getLabel(BuildContext context) =>Text(
    label.toUpperCase(),
    textAlign: TextAlign.center,
    style: TextStyle(
      color: labelColor ?? context.textColor,
      fontSize: context.scale(labelSize),
    ),
  );
}
