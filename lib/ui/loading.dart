import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/wifi.dart';
import '../model/data.dart';
import 'home_page.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 50,
          child: Image.asset('images/icon.png'),
        ),
      ),
    );
  }

  load() async {
    prefs = await SharedPreferences.getInstance();
    final bool result = await platform.invokeMethod('permission');
    if (result == true) {
      String pass = prefs.getString('homePass');
      if (pass == null) {
        homeSSID = await Wifi.ssid;
        while (homeSSID == "<unknown ssid>") {
          homeSSID = await Wifi.ssid;
        }
        prefs.setString('homeSSID', homeSSID);
      } else {
        homeSSID = prefs.getString('homeSSID');
        homePass = prefs.getString('homePass');
      }
      Future.delayed(Duration(seconds: 1)).then((value) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      });
    }
  }
}
