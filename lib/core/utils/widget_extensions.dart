import 'package:bando/core/widgets/show_up_widget.dart';
import 'package:flutter/material.dart';

extension Paddings on Widget {
  Widget paddingAll(double value) => Padding(
        padding: EdgeInsets.all(value),
        child: this,
      );

  Widget paddingOnly({
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
    double left = 0.0,
  }) =>
      Padding(
        padding: EdgeInsets.only(
          top: top,
          right: right,
          bottom: bottom,
          left: left,
        ),
        child: this,
      );
}

extension WidgetAnimatons on Widget {
  Widget showFromBottomAnimation(int positionInOrder) => ShowUpWidget(
        child: this,
        positionInOrder: positionInOrder,
      );
}
