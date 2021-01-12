import 'package:flutter/material.dart';
import 'package:show_up_animation/show_up_animation.dart';

class ShowUpWidget extends StatelessWidget {
  final Widget child;
  final int positionInOrder;

  ShowUpWidget({@required this.child, this.positionInOrder = 1});

  @override
  Widget build(BuildContext context) {
    return ShowUpAnimation(
      child: child,
      delayStart: Duration(milliseconds: (positionInOrder * 90)),
      animationDuration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCirc,
      direction: Direction.vertical,
      offset: 0.3,
    );
  }
}
