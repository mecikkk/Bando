import 'package:bando/core/utils/constants.dart';
import 'package:bando/core/utils/context_extensions.dart';
import 'package:bando/core/widgets/shake_animation.dart';
import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:flutter/material.dart';

class ConnectivityBar extends StatelessWidget {

  final GlobalKey<ShakeAnimationState> _shakerKey = GlobalKey<ShakeAnimationState>();
  final Function(bool isOnline) currentStatus;

  ConnectivityBar({@required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    return ShakeAnimation(
      key: _shakerKey,
      child: ConnectivityWidget(
        offlineBanner: Container(
          height: 34,
          decoration: BoxDecoration(
              color: context.colors.failure,
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: Offset(0, 0),
                  color: Colors.black.withOpacity(0.5),
                )
              ]),
          child: Center(
            child: Text(
              context.translate(Texts.NO_CONNECTION),
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        builder: (context, isOnline) {
          currentStatus(isOnline);
          return SizedBox();
        },
      ),
    );
  }

  void shake() {
    _shakerKey.currentState.shake();
  }

}