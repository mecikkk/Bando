import 'package:flutter/cupertino.dart';

class AnimatedOpacityWidget extends AnimatedWidget {

  final Widget child;

  AnimatedOpacityWidget({this.child, opacity}) : super (listenable : opacity);

  Animation<double> get opacity => listenable;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.value,
      child: child,
    );
  }

}