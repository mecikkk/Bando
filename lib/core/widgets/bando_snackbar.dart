import 'package:bando/core/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:bando/core/utils/context_extensions.dart';

enum _SnackType {ERROR, INFO, WARNING, SUCCESS}

class BandoSnackBar extends StatelessWidget {
  final String message;
  final IconData icon;
  final _SnackType _type;

  BandoSnackBar({
    @required this.message,
    this.icon,
  }) : _type = _SnackType.INFO;

  BandoSnackBar.error({@required this.message, this.icon}) : _type = _SnackType.ERROR;
  BandoSnackBar.info({@required this.message, this.icon}) : _type = _SnackType.INFO;
  BandoSnackBar.warning({@required this.message, this.icon}) : _type = _SnackType.WARNING;
  BandoSnackBar.success({@required this.message, this.icon}) : _type = _SnackType.SUCCESS;


  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color bgColor;

    switch(_type) {
      case _SnackType.ERROR:
        bgColor = context.colors.failure;
        textColor = Colors.black;
        break;
      case _SnackType.INFO:
        bgColor =  context.textColor;
        textColor = context.bgColor;
        break;
      case _SnackType.WARNING:
        bgColor = Colors.amber;
        textColor = Colors.black;
        break;
      case _SnackType.SUCCESS:
        bgColor = context.colors.success;
        textColor = Colors.black;
        break;
    }


    return SnackBar(
      backgroundColor: bgColor,
      behavior: SnackBarBehavior.floating,
      content: Row(
        children: [
          (icon != null)
              ? Icon(
                  icon,
                  color: textColor,
                )
              : (_type == _SnackType.ERROR)
                  ? Icon(
                      Icons.error_outline_rounded,
                      color: textColor,
                    )
                  : Icon(
                      Icons.info_outlined,
                      color: textColor,
                    ),
          SizedBox(width: 16.0,),
          Text(
            context.translate(message),
            style: TextStyle(color: textColor),
          ),
        ],
      ),
    );
  }
}
