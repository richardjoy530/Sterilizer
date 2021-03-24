import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
    super.initState();
    contextStack.add(this.context);
    load();
  }

  @override
  void dispose() {
    contextStack.remove(this.context);
    super.dispose();
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
    // Fluttertoast.showToast(msg: "Loading");
    // await Future.delayed(Duration(seconds: 4));
    prefs = await SharedPreferences.getInstance();
    deviceId = prefs.getInt("deviceID") ?? 0;
    var numOfDevices = prefs.getInt("num_devices") ?? 0;
    if (numOfDevices > 0) {
      deviceList.add(Device.fromMemory(prefs: prefs));
    }
    // Fluttertoast.showToast(msg: "Before asking permission");
    // await Future.delayed(Duration(seconds: 3));
    final bool result = await platform.invokeMethod('permission');
    String ssid = await platform.invokeMethod('ssid');
    Fluttertoast.showToast(msg: "Method channel ssid: $ssid");
    await Future.delayed(Duration(seconds: 5));
    if (result == true) {
      String pass = prefs.getString('homePass');
      if (pass == null) {
        homeSSID = await Wifi.ssid;
        Fluttertoast.showToast(msg: homeSSID);
        while (homeSSID == "<unknown ssid>") {
          homeSSID = await Wifi.ssid;
          Fluttertoast.showToast(msg: homeSSID);
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
