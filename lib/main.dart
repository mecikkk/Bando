
import 'package:flutter/material.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  runApp(
    BandoApp()

  );
}

class BandoApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      title: 'Bando',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      home: Scaffold(
        body: Text("BandoApp"),
      )
    );
  }

}
