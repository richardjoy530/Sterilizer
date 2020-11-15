import 'dart:io';
import 'dart:math';

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
List<Device> deviceList = [];

class Device {
  String name;
  int id;
  bool uv;
  int mode;

  Device({this.name, this.uv, this.mode}) {
    id = Random().nextInt(5000);
    var fire = FirebaseManager();
    fire.add(id);
    saveToMemory();
    listenChanges();
  }

  Device.fromMemory({SharedPreferences prefs}) {
    name = prefs.getString("device_name");
    id = prefs.getInt("device_id");
    uv = prefs.getBool("device_uv");
    mode = prefs.getInt("device_mode");
    update();
    listenChanges();
  }

  saveToMemory() {
    prefs.setInt("num_devices", 1);
    prefs.setString("device_name", name);
    prefs.setInt("device_id", id);
    prefs.setBool("device_uv", uv);
    prefs.setInt("device_mode", mode);
  }

  update() async {
    var fire = FirebaseManager();
    print(uv);
    await fire.sync(this);
    print([uv, "After syncing"]);
  }

  listenChanges() {
    var fire = FirebaseManager();
    fire.db.child(id.toString()).onChildChanged.listen((event) {
      print(event.snapshot.value);
    });
  }

  toggleMode(int mode) async {
    this.mode=mode;
    var fire = FirebaseManager();
    await fire.setMode(id,mode);
  }

  switchUV(bool uv) async {
    var fire = FirebaseManager();
    await fire.switchUV(id,uv);
  }
}
