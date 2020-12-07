import 'dart:async';

import 'package:Sterilizer/model/data.dart';
import 'package:flutter/material.dart';
import 'package:wifi/wifi.dart';

class ChangeWifi extends StatefulWidget {
  @override
  _ChangeWifiState createState() => _ChangeWifiState();
}

class _ChangeWifiState extends State<ChangeWifi> {
  TextEditingController passwordController;
  String tempSSID;
  Timer _timer;

  @override
  void initState() {
    tempSSID = "New Wifi";
    contextStack.add(this.context);
    passwordController = TextEditingController();
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      Wifi.ssid.then((value) => setState(() => tempSSID = value));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    contextStack.remove(this.context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            margin: EdgeInsets.only(top: 30, bottom: 30),
            child: ListTile(
              title: Text(
                "Change your device Wifi",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(
              child: CircularProgressIndicator(backgroundColor: Colors.black12),
            ),
          ),
          Container(
            child: ListTile(
              title: Text(
                "Make sure your phone is connected to the new wifi",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.wifi_lock_rounded),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(tempSSID),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    labelText: "Password",
                    focusColor: Colors.black,
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Colors.black,
                        style: BorderStyle.solid,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Colors.black,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                  controller: passwordController,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Color(0xff060606),
                  child: Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    prefs.remove('homePass');
                    prefs.remove('homeSSID');
                    prefs.setString('homePass', passwordController.text);
                    prefs.setString("homeSSID", tempSSID);
                    homePass = passwordController.text;
                    homeSSID = tempSSID;
                    Navigator.pop(context);
                  }),
            ),
          )
        ],
      ),
    );
  }
}
