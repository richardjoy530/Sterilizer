import 'dart:io';

import 'package:Sterilizer/utils/firebase_manager.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

String homeSSID;
String homePass;
SharedPreferences prefs;
ServerSocket serverSocket;
const String DEVICE_SSID = 'razecov';
const String DEVICE_PASSWORD = 'razecov123';
const platform = const MethodChannel('com.ibis.sterilizer/channel');
String homeName = 'My Home';
String userId = "00001";
List<Device> deviceList=[];

class Device {
  String name;
  bool power;
  String room;
  Device(this.name,this.power,this.room) {
    final Map<String, dynamic> deviceData = {
      "room": room,
      "power": power,
    };
    var fire = FirebaseManager();
    fire.add(deviceData, name);
  }

  update(){
    final Map<String, dynamic> deviceData = {
      "room": room,
      "power": power,
    };
    var fire = FirebaseManager();
    fire.add(deviceData, name);
  }

  toggleMode() async {
    var fire = FirebaseManager();
    await fire.addToggles();
  }

}
