import 'package:flutter/material.dart';
import 'ui/loading.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Sterilizer',
        theme: ThemeData(fontFamily: 'Roboto', accentColor: Colors.black),
        home: Loading());
  }
}
