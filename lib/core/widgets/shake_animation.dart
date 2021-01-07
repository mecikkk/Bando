import 'package:flutter/material.dart';

class ShakeAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double offset;
  final Axis axis;
  final Curve curve;

  ShakeAnimation({
    Key key,
    @required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.offset = 150.0,
    this.axis,
    this.curve = Curves.bounceIn,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ShakeAnimationState();
  }
}

class ShakeAnimationState extends State<ShakeAnimation> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation _leftPadding;
  Animation _rightPadding;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _leftPadding = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween(begin: 16.0, end: 24.0).chain(CurveTween(curve: Curves.linear)),
          weight: 20.0
        ),
        TweenSequenceItem<double>(
            tween: Tween(begin: 24.0, end: 8.0).chain(CurveTween(curve: Curves.linear)),
            weight: 20.0
        ),
        TweenSequenceItem<double>(
            tween: Tween(begin: 8.0, end: 20.0).chain(CurveTween(curve: Curves.linear)),
            weight: 20.0
        ),
        TweenSequenceItem<double>(
            tween: Tween(begin: 20.0, end: 12.0).chain(CurveTween(curve: Curves.linear)),
            weight: 20.0
        ),
        TweenSequenceItem<double>(
            tween: Tween(begin: 12.0, end: 16.0).chain(CurveTween(curve: Curves.linear)),
            weight: 20.0
        ),
      ],
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _rightPadding = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
            tween: Tween(begin: 16.0, end: 8.0).chain(CurveTween(curve: Curves.linear)),
            weight: 20.0
        ),
        TweenSequenceItem<double>(
            tween: Tween(begin: 8.0, end: 24.0).chain(CurveTween(curve: Curves.linear)),
            weight: 20.0
        ),
        TweenSequenceItem<double>(
            tween: Tween(begin: 24.0, end: 12.0).chain(CurveTween(curve: Curves.linear)),
            weight: 20.0
        ),
        TweenSequenceItem<double>(
            tween: Tween(begin: 12.0, end: 20.0).chain(CurveTween(curve: Curves.linear)),
            weight: 20.0
        ),
        TweenSequenceItem<double>(
            tween: Tween(begin: 20.0, end: 16.0).chain(CurveTween(curve: Curves.linear)),
            weight: 20.0
        ),
      ],
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _controller.value = 16.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.only(left: _leftPadding.value, right: _rightPadding.value),
          child: widget.child,
        );
      },
    );
  }

  void shake() {
    debugPrint("Start shaking");
    _controller.reset();
    _controller.forward();
  }
}
