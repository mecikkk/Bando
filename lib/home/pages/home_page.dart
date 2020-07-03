
import 'package:bando/file_manager/widgets/file_manager_list_view.dart';
import 'package:bando/home/pages/leader_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Future<void> initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Brightness _systemNavIcons;
    debugPrint("Brightness : ${Theme.of(context).brightness}");
    if(Theme.of(context).brightness == Brightness.light) _systemNavIcons = Brightness.dark;
      else _systemNavIcons = Brightness.light;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
          systemNavigationBarIconBrightness: _systemNavIcons
      ),
    );

    return Scaffold(
        body: LeaderHomePage()
    );
  }
}