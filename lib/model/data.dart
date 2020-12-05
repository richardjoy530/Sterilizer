import 'dart:io';
import 'dart:math';

import 'package:Sterilizer/utils/firebase_manager.dart';
import 'package:Sterilizer/utils/popups.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

BuildContext context;
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
  bool motionDetected = false;
  bool appConnected=true;
  FirebaseManager firebaseManager;
  Null Function() state;

  Device({this.name, this.uv}) {
    id = Random().nextInt(5000);
    firebaseManager = FirebaseManager();
    firebaseManager.add(id);
    saveToMemory();
    listenChanges();
  }

  setTheState(Null Function() param0){
    state = param0;
  }


  Device.fromMemory({SharedPreferences prefs}) {
    name = prefs.getString("device_name");
    id = prefs.getInt("device_id");
    uv = prefs.getBool("device_uv");
    firebaseManager = FirebaseManager();
    firebaseManager.db.child(id.toString()).child("appConnected").set(1);
    update();
    listenChanges();
  }

  saveToMemory() {
    prefs.setInt("num_devices", 1);
    prefs.setString("device_name", name);
    prefs.setInt("device_id", id);
    prefs.setBool("device_uv", uv);
  }

  update() async {
    print(uv);
    await firebaseManager.sync(this);
    print([uv, "After syncing"]);
  }

  listenChanges() {
    firebaseManager.db.child(id.toString()).onChildChanged.listen((event) {
      print({[event.snapshot.key,event.snapshot.value]});
      firebaseManager.db.child(id.toString()).child("appConnected").set(1);
      if(event.snapshot.key=="motionDetected"&&event.snapshot.value==1) {
        motionDetected = true;
        motionDetectedPopUp();
        switchUV(false);
        state.call();
      }
    });
  }

  switchUV(bool uv) async {
    await firebaseManager.switchUV(id,uv);
  }
}
