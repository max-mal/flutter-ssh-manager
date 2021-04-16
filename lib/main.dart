
import 'package:flutter/material.dart';
import 'package:mgr/ui/list.dart';

void main() async {  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SSH Manager',
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        /* dark theme settings */
      ),
      themeMode: ThemeMode.dark, 
      home: UiList(),
    );
  }
}
