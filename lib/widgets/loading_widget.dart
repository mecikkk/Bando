import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      child: Container(
       child: CircularProgressIndicator(),
      ),
    );
  }

}