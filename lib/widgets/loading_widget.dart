import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

enum LoadingType { CLOUD_PROGRESS, LOADING }

class LoadingWidget extends StatelessWidget {
  final String text;
  final LoadingType loadingType;

  LoadingWidget({this.text = "", @required this.loadingType});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height:  MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          (loadingType == LoadingType.LOADING)
              ? SizedBox(
                  height: 80,
                  width: 80,
                  child: CircularProgressIndicator(),
                )
              : Lottie.asset(
                  "assets/uploading_animation.json",
                  repeat: true,
                  width: 150,
                  height: 150,
                ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              text,
              style: TextStyle(fontSize: 18.0),
            ),
          )
        ],
      ),
    );
  }
}
