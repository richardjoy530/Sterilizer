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
String deviceIdTemp = "-1";
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
  String id;

// 3 health metrics
// 1 => HEPA filter = MAX =
// 2 => Purification
// 3 => Disinfection

  int value1 = 000000;
  int value2 = 000000;

  String settings = '';

  int get hepaHealth => 100 - (value1.remainder(270000) ~/ 2700);
  int get purficationHealth => 100 - (value1 ~/ 5400);
  int get disinfectionHealth => 100 - (value2 ~/ 5400);

  String connectedWifi = "Checking..";
  bool isWifiDirty = false;

  String name = 'Device';
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
    watch();
  }

  Device.fromDB({this.name, this.id, this.schedules, this.settings}) {
    sync();
    watch();
  }

  Device.fromFire({this.name, this.id}) {
    FirebaseManager.getDevice(this).then((device) {
      DataBaseHelper.addDevice(this);
      sync();
      watch();
    });
    homePageSetState?.call();
    devicePageSetState?.call();
  }

  sync() async {
    await FirebaseManager.sync(this);
    if (disinfectionHealth <= 0) {
      unhealthyPopup(
          this,
          "Disinfection UVC Tube is expired please change the tube.",
          "Change Tube",
          3);
    }
    if (purficationHealth <= 0) {
      unhealthyPopup(
          this,
          "Purification UVC Tube is expired please change the tube.",
          "Change Tube",
          2);
    }
    if (purficationHealth <= 50 && settings != "reset") {
      unhealthyPopup(this, "Hepa filter is expired please change the tube.",
          "Change Filter", 1);
    }
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

  watch() {
    FirebaseManager.db.child(id.toString()).onChildChanged.listen((event) {
      // Motion
      if (event.snapshot.key == "uv" && event.snapshot.value == "OFF1") {
        motionDetectedPopUp(this);
        uv = false;
        isUVDirty = true;
        updateDevice();
        if (context.widget.runtimeType == DevicePage)
          devicePageSetState?.call();
      } else if (event.snapshot.key == "lifespan") {
        this.value1 =
            int.parse(event.snapshot.value.toString().substring(0, 6));
        this.value2 = int.parse(event.snapshot.value.toString().substring(7));
        if (disinfectionHealth <= 0) {
          unhealthyPopup(
              this,
              "Disinfection UVC Tube is expired please change the tube.",
              "Change Tube",
              3);
        }
        if (purficationHealth <= 0) {
          unhealthyPopup(
              this,
              "Purification UVC Tube is expired please change the tube.",
              "Change Tube",
              2);
        }
        if (hepaHealth <= 0 && settings != "reset") {
          unhealthyPopup(this, "Hepa filter is expired please change the tube.",
              "Change Filter", 1);
        }
      }
    });
  }

  resetMotion() {
    FirebaseManager.motionReset(this);
  }

  resetHealth(int option) {
    if (option == 1) {
      settings = "reset";
      DataBaseHelper.changedHEPAfilter(this, "reset");
    } else if (option == 2) {
      settings = "fresh";
      DataBaseHelper.changedHEPAfilter(this, "fresh");
    }
    FirebaseManager.healthReset(this, option);
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
      String deviceId}) {
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
