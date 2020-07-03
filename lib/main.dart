import 'package:flutter/material.dart';

import 'file_manager/widgets/file_manager_list_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bando',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xfff3f4f9),
        accentColor: Color.fromRGBO(168, 0, 79, 1.0),
        scaffoldBackgroundColor: Color(0xfff3f4f9),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Varela',
      ),
      home: FileManagerListView(),
    );
  }
}
