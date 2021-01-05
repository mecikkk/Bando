import 'package:bando/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';

class LogoLoading extends StatefulWidget {
  LogoLoading({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LogoLoadingState();
}

class LogoLoadingState extends State<LogoLoading> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  bool _repeat = false;

  Animation _micro;
  Animation _stand;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _stand = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween(begin: 100.0, end: 110.0).chain(CurveTween(curve: Curves.easeOutCirc)),
          weight: 50.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween(begin: 110.0, end: 90.0).chain(CurveTween(curve: Curves.linear)),
          weight: 25.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween(begin: 90.0, end: 100.0).chain(CurveTween(curve: Curves.easeOutCirc)),
          weight: 25.0,
        ),
      ],
    ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.1, 0.6, curve: Curves.linear)));

    _micro = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween(begin: 10.0, end: 0.0).chain(CurveTween(curve: Curves.easeOutCirc)),
          weight: 50.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween(begin: 0.0, end: 10.0).chain(CurveTween(curve: Curves.easeInCirc)),
          weight: 50.0,
        ),
      ],
    ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.6, 1.0, curve: Curves.linear)));

    _controller.addStatusListener((status) {
      if (!_repeat && status == AnimationStatus.completed) {
        _controller.reset();
        _controller.stop();
      }
    });
  }

  void startAnim() {
    if (!_repeat) {
      _repeat = true;
      _controller.forward();
      _controller.repeat();
    }
  }

  void stopAnim() {
    if (_repeat) {
      setState(() {
        _repeat = false;
        _controller.forward();
      });
    }
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
      builder: (context, widget) {
        return Container(
          height: context.scale(200.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: context.scale(_micro.value),
                left: 0.0,
                right: 0.0,
                child: Image.asset(
                  'assets/micro_b.png',
                  height: context.scale(125.0),
                ),
              ),
              Positioned(
                top: context.scale(_stand.value),
                child: Image.asset(
                  'assets/stand.png',
                  width: context.scale(125.0),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
