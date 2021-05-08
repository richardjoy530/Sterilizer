import 'dart:io';

import 'package:Sterilizer/ui/device_page.dart';
import 'package:Sterilizer/utils/firebase_manager.dart';
import 'package:Sterilizer/utils/popups.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

BuildContext get context => contextStack.last;
List<BuildContext> contextStack = [];
String homeSSID;
String homePass;
SharedPreferences prefs;
ServerSocket serverSocket;
const String DEVICE_SSID = 'razecov';
int deviceId = -1;
const String DEVICE_PASSWORD = 'razecov123';
const platform = const MethodChannel('com.ibis.sterilizer/channel');
String homeName = 'Dashboard';
List<Device> deviceList = [];

class RegistrationProcess {
  static const String PREPARING = "Preparing network details";

  static const String SEARCHING = "Searching for devices";

  static const String ESTABLISHING = "Establishing connection with the device";

  static const String REGISTERING = "Registering device";

  static const String WAITING = "Waiting for device to be online";

  static const String FINISHING = "Finishing setup";

  static const String OVER = "OVER";

  static String currentStatusString = SEARCHING;

  static int currentStatus = 0;

  static changeStatus(String status) {
    if (status == PREPARING)
      currentStatus = 0;
    else if (status == SEARCHING)
      currentStatus = 1;
    else if (status == ESTABLISHING)
      currentStatus = 2;
    else if (status == REGISTERING)
      currentStatus = 3;
    else if (status == WAITING)
      currentStatus = 4;
    else if (status == FINISHING)
      currentStatus = 5;
    else if (status == OVER) currentStatus = 6;
  }
}

class Device {
  String name;
  int id;
  bool uv;
  bool motionDetected = false;
  bool appConnected = true;
  List<ScheduleData> schedules = [];
  Null Function() _state;

  Device({this.name, this.uv}) {
    id = deviceId;
    FirebaseManager.add(this);
    saveToMemory();
    listenChanges();
  }

  setTheState(Null Function() param0) {
    _state = param0;
  }

  Device.fromMemory({SharedPreferences prefs}) {
    name = prefs.getString("device_name") ?? 'Device';
    id = prefs.getInt("device_id");
    uv = false;
    (prefs.getStringList("schedules") ?? []).forEach((element) {
      schedules.add(ScheduleData.fromString(element));
    });
    sync();
    listenChanges();
  }

  saveToMemory() {
    List<String> temp = [];
    schedules.forEach((element) {
      temp.add(element.stringify());
    });
    prefs.setInt("num_devices", 1);
    prefs.setString("device_name", name);
    prefs.setInt("device_id", id);
    prefs.setBool("device_uv", uv);
    prefs.setStringList("schedules", temp);
  }

  sync() async {
    await FirebaseManager.sync(this);
  }

  updateSchedules() async {
    saveToMemory();
    await FirebaseManager.updateSchedules(this);
  }

  listenChanges() {
    FirebaseManager.db.child(id.toString()).onChildChanged.listen((event) {
      if (event.snapshot.key == "motionDetected" && event.snapshot.value == 2) {
        motionDetected = true;
        motionDetectedPopUp(this);
        uv = false;
        switchUV();
        if (context.widget.runtimeType == DevicePage) _state.call();
      }
    });
  }

  motionReset() {
    FirebaseManager.motionReset(this);
  }

  switchUV() async {
    await FirebaseManager.switchUV(this);
  }
}

class ScheduleData {
  TimeOfDay startTime;
  TimeOfDay endTime;
  bool state;
  List<bool> days = [true, true, true, true, true, true, true];

  ScheduleData(this.startTime, this.endTime, this.state, this.days);

  ScheduleData.fromString(String dataInString) {
    var temp = dataInString.split(' ');
    startTime = TimeOfDay(hour: int.parse(temp[0]), minute: int.parse(temp[1]));
    endTime = TimeOfDay(hour: int.parse(temp[2]), minute: int.parse(temp[3]));
    state = temp[4] == "false" ? false : true;
    days[0] = temp[5] == "false" ? false : true;
    days[1] = temp[6] == "false" ? false : true;
    days[2] = temp[7] == "false" ? false : true;
    days[3] = temp[8] == "false" ? false : true;
    days[4] = temp[9] == "false" ? false : true;
    days[5] = temp[10] == "false" ? false : true;
    days[6] = temp[11] == "false" ? false : true;
  }

  String stringify() {
    String temp = startTime.hour.toString() +
        " " +
        startTime.minute.toString() +
        " " +
        endTime.hour.toString() +
        " " +
        endTime.minute.toString() +
        " " +
        state.toString() +
        " " +
        days.toString();
    return temp.replaceAll("[", '').replaceAll("]", '').replaceAll(",", '');
  }
}
