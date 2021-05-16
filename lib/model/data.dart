import 'dart:io';

import 'package:Sterilizer/model/db_helper.dart';
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
ServerSocket serverSocket;
const String DEVICE_SSID = 'razecov';
int deviceIdTemp = -1;
String deviceNameTemp = "";
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

  static const String OVER = "Finished";

  static String currentStatusString = SEARCHING;

  static int currentStatus = 0;

  static changeStatus(String status) {
    if (status == PREPARING) {
      currentStatus = 0;
      currentStatusString = PREPARING;
    } else if (status == SEARCHING) {
      currentStatus = 1;
      currentStatusString = SEARCHING;
    } else if (status == ESTABLISHING) {
      currentStatus = 2;
      currentStatusString = ESTABLISHING;
    } else if (status == REGISTERING) {
      currentStatus = 3;
      currentStatusString = REGISTERING;
    } else if (status == WAITING) {
      currentStatus = 4;
      currentStatusString = WAITING;
    } else if (status == FINISHING) {
      currentStatus = 5;
      currentStatusString = FINISHING;
    } else if (status == OVER) {
      currentStatus = 6;
      currentStatusString = OVER;
    }
  }
}

enum AddDeviceChoice { ExistingDevice, NewDevice, Invalid }

class Device {
  int id;

  String connectedWifi = "Checking..";
  bool isWifiDirty = false;

  String name='Device';
  bool isNameDirty = false;

  bool uv = false;
  bool isUVDirty = false;

  List<ScheduleData> schedules = [];
  bool isSchedulesDirty = false;

  void Function() devicePageSetState;
  static void Function() homePageSetState;
  void Function() schedulePageSetState;

  setSchedulePageState(void Function() param0) => schedulePageSetState = param0;

  static setHomePageState(void Function() param0) => homePageSetState = param0;

  setDevicePageState(void Function() param0) => devicePageSetState = param0;

  Device.newDevice({this.name, this.id, this.connectedWifi}) {
    FirebaseManager.add(this);
    DataBaseHelper.addDevice(this);
    watchForMotion();
  }

  Device.fromDB({this.name, this.id, this.schedules}) {
    sync();
    watchForMotion();
  }

  Device.fromFire({this.name, this.id}) {
    FirebaseManager.getDevice(this).then((device) {
      DataBaseHelper.addDevice(this);
      sync();
      watchForMotion();
    });
    homePageSetState?.call();
    devicePageSetState?.call();
  }

  sync() async {
    await FirebaseManager.sync(this);
    homePageSetState?.call();
    devicePageSetState?.call();
  }

  updateDevice() async {
    //--------Firebase--
    if (isUVDirty) FirebaseManager.updateUV(this);
    if (isSchedulesDirty) FirebaseManager.updateSchedules(this);
    if (isWifiDirty) {
      FirebaseManager.updateWifi(this);
      devicePageSetState?.call();
      homePageSetState?.call();
    }

    //--------DB--------
    if (isNameDirty) {
      DataBaseHelper.updateDevice(this);
      homePageSetState?.call();
      devicePageSetState?.call();
    }
    schedules.forEach((scheduleData) {
      if (scheduleData.isDirty) DataBaseHelper.updateSchedule(scheduleData);
      scheduleData.isDirty = false;
    });
    isUVDirty = false;
    isNameDirty = false;
    isSchedulesDirty = false;
    isWifiDirty = false;
  }

  deleteDevice() async {
    DataBaseHelper.removeDevice(this);
    schedules.forEach((scheduleData) {
      DataBaseHelper.removeSchedule(scheduleData.scheduleId);
    });
  }

  watchForMotion() {
    FirebaseManager.db.child(id.toString()).onChildChanged.listen((event) {
      if (event.snapshot.key == "motionDetected" && event.snapshot.value == 2) {
        motionDetectedPopUp(this);
        uv = false;
        isUVDirty=true;
        updateDevice();
        if (context.widget.runtimeType == DevicePage)
          devicePageSetState?.call();
      }
    });
  }

  resetMotion() {
    FirebaseManager.motionReset(this);
  }
}

class ScheduleData {
  bool isDirty = false;
  int scheduleId;

  TimeOfDay _startTime;

  set startTime(TimeOfDay startTime) {
    isDirty = true;
    this._startTime = startTime;
  }

  TimeOfDay get startTime => this._startTime;

  TimeOfDay _endTime;

  set endTime(TimeOfDay endTime) {
    isDirty = true;
    this._endTime = endTime;
  }

  TimeOfDay get endTime => this._endTime;

  bool _state;

  set state(bool state) {
    isDirty = true;
    this._state = state;
  }

  bool get state => this._state;

  List<bool> _days = [true, true, true, true, true, true, true];

  set days(List<bool> days) {
    isDirty = true;
    print("setting fo days");
    this._days = days;
  }

  List<bool> get days => this._days;

  ScheduleData(
      {TimeOfDay startTime,
      TimeOfDay endTime,
      bool state,
      List<bool> days,
      int deviceId}) {
    this.startTime = startTime;
    this.endTime = endTime;
    this.state = state;
    this.days = days;
    scheduleId = DateTime.now().millisecondsSinceEpoch;
    DataBaseHelper.addSchedule(this, deviceId);
  }

  deleteSchedule() {
    DataBaseHelper.removeSchedule(scheduleId);
  }

  ScheduleData.fromString(String dataInString, int id) {
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
    scheduleId = id;
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
