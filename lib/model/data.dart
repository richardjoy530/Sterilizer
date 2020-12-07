import 'dart:io';

import 'package:Sterilizer/ui/device_page.dart';
import 'package:Sterilizer/utils/firebase_manager.dart';
import 'package:Sterilizer/utils/popups.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

BuildContext get context => contextStack.last;
List<BuildContext> contextStack=[];
String homeSSID;
String homePass;
SharedPreferences prefs;
ServerSocket serverSocket;
const String DEVICE_SSID = 'razecov';
int deviceId = 0;
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
    id = deviceId;
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
      if(event.snapshot.key=="motionDetected"&&event.snapshot.value==2) {
        motionDetected = true;
        motionDetectedPopUp(this);
        switchUV(false);
        print([context.widget,context.runtimeType,context.findRenderObject()]);
        if(context.widget.runtimeType==DevicePage)state.call();
        uv=false;
      }
    });
  }

  motionReset(){
    firebaseManager.db.child(id.toString()).child("motionDetected").set(1);
  }

  switchUV(bool uv) async {
    await firebaseManager.switchUV(id,uv);
  }
}
