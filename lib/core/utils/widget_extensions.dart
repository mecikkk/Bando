import 'package:flutter/material.dart';
import 'package:show_up_animation/show_up_animation.dart';

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
  Widget showFromBottomAnimation(int positionInOrder) => ShowUpAnimation(
    child: this,
    delayStart: Duration(milliseconds: (positionInOrder * 50)),
    animationDuration: const Duration(milliseconds: 550),
    curve: Curves.easeOutCirc,
    direction: Direction.vertical,
    offset: 0.3,
  );
}
