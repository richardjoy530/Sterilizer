import 'dart:math';
import 'package:intl/intl.dart';

import 'package:Sterilizer/model/data.dart';
import 'package:Sterilizer/utils/popups.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

String localStates = "";

class FirebaseManager {
  static DatabaseReference db = FirebaseDatabase.instance.reference();

  static add(Device device) {
    // db.child(device.id).child("motionDetected").set(1);
    db.child(device.id).child("uv").set("OFF");
    db.child(device.id).child("connectedWifi").set(device.connectedWifi);
    db.child(device.id).child("lifespan").set("000000,000000");

    Map<String, dynamic> schedulesMap = {
      '0': [""],
      '1': [""],
      '2': [""],
      '3': [""],
      '4': [""],
      '5': [""],
      '6': [""],
    };
    db.child(device.id).child("schedules").set(schedulesMap);
  }

  static updateUV(Device device) async {
    if (device.uv)
      db.child(device.id).child("uv").set("ON");
    else
      db.child(device.id).child("uv").set("OFF");
  }

  static updateWifi(Device device) {
    db.child(device.id).child("connectedWifi").set(device.connectedWifi);
  }

  static sync(Device device) async {
    await db.child(device.id).child("uv").once().then((value) => device.uv =
        value.value == "OFF" || value.value == "OFF1" ? false : true);
    await db
        .child(device.id)
        .child("connectedWifi")
        .once()
        .then((value) => device.connectedWifi = value.value);

    await db.child(device.id).child("lifespan").once().then((value) {
      device.value1 = int.parse(value.value.toString().substring(0, 6));
      device.value2 = int.parse(value.value.toString().substring(7));
    });

    // Checking if motion was detected previously and machine was stopped.
    await db.child(device.id).child("uv").once().then((value) {
      if (value.value == "OFF1") motionDetectedPopUp(device);
    });
  }

  static updateSchedules(Device device) {
    // List<Map<String, dynamic>> mapList = [];
    // device.schedules.forEach((element) {
    //   var start =
    //       element.startTime.hour * 60 * 60 + element.startTime.minute * 60;
    //   var end = element.endTime.hour * 60 * 60 + element.endTime.minute * 60;
    //   if (element.state)
    //     mapList.add({
    //       "endStamp": end,
    //       "startStamp": start,
    //       "dayStamp": encodeScheduleDays(element),
    //     });
    // });

    // each schedule will have start,end, state
    // sunday => 0 : ["(11:00-13:00)"]

    Map<String, List<dynamic>> schedulesMap = {
      '0': [""],
      '1': [""],
      '2': [""],
      '3': [""],
      '4': [""],
      '5': [""],
      '6': [""],
    };
    Map<String, List<List<TimeOfDay>>> rawMap = {
      '0': [],
      '1': [],
      '2': [],
      '3': [],
      '4': [],
      '5': [],
      '6': [],
    };

    device.schedules.forEach((schedule) {
      // print(schedule.toString());
      if (schedule.state) {
        if (schedule.days[0])
          rawMap['0'].add([schedule.startTime, schedule.endTime]);
        if (schedule.days[1])
          rawMap['1'].add([schedule.startTime, schedule.endTime]);
        if (schedule.days[2])
          rawMap['2'].add([schedule.startTime, schedule.endTime]);
        if (schedule.days[3])
          rawMap['3'].add([schedule.startTime, schedule.endTime]);
        if (schedule.days[4])
          rawMap['4'].add([schedule.startTime, schedule.endTime]);
        if (schedule.days[5])
          rawMap['5'].add([schedule.startTime, schedule.endTime]);
        if (schedule.days[6])
          rawMap['6'].add([schedule.startTime, schedule.endTime]);
      }
    });

    rawMap.forEach((key, value) {
      value.sort((a, b) => a[0].hour.compareTo(b[0].hour));
      String timeList = "";
      if (value.length != 0) {
        value.forEach((element) {
          timeList += getTimeString(element[0], element[1]);
        });
      }
      schedulesMap[key] = [timeList];
    });

    print(rawMap);
    db.child(device.id).child("schedules").set(schedulesMap);
  }

  static void motionReset(Device device) {
    db.child(device.id).child("uv").set("OFF");
  }

  static String getTimeString(TimeOfDay a, TimeOfDay b) {
    return "(${a.hour}:${a.minute}-${b.hour}:${b.minute})";
  }

  static String encodeScheduleDays(ScheduleData scheduleData) {
    String encodedValue = "0000000";
    var dayBool = scheduleData.stringify().split(" ");
    if (dayBool[4 + 1] == "true")
      encodedValue = encodedValue.replaceRange(0, 1, '1');
    if (dayBool[4 + 2] == "true")
      encodedValue = encodedValue.replaceRange(1, 2, '1');
    if (dayBool[4 + 3] == "true")
      encodedValue = encodedValue.replaceRange(2, 3, '1');
    if (dayBool[4 + 4] == "true")
      encodedValue = encodedValue.replaceRange(3, 4, '1');
    if (dayBool[4 + 5] == "true")
      encodedValue = encodedValue.replaceRange(4, 5, '1');
    if (dayBool[4 + 6] == "true")
      encodedValue = encodedValue.replaceRange(5, 6, '1');
    if (dayBool[4 + 7] == "true")
      encodedValue = encodedValue.replaceRange(6, 7, '1');
    return encodedValue;
  }

  static Future<bool> checkForExistingDevice(String deviceId) async {
    var result = await db.child(deviceId).once();
    if (result.value != null) return true;
    return false;
  }

  static Future<Device> getDevice(Device device) async {
    await db.child(device.id).child("uv").once().then((value) => device.uv =
        value.value == "OFF" || value.value == "OFF1" ? false : true);
    await db.child(device.id).child("lifespan").once().then((value) {
      device.value1 = int.parse(value.value.toString().substring(0, 6));
      device.value2 = int.parse(value.value.toString().substring(7));
    });
    await db
        .child(device.id)
        .child("connectedWifi")
        .once()
        .then((value) => device.connectedWifi = value.value);
    await db.child(device.id).child("schedules").once().then((value) {
      print(value);
    });
    return device;
  }

  static void healthReset(Device device, int option) {
    NumberFormat formatter = new NumberFormat("000000");
    if (option == 2) {
      device.value1 = 0;
    } else if (option == 3) {
      device.value2 = 0;
    }
    db.child(device.id).child("lifespan").set(
        "${formatter.format(device.value1)},${formatter.format(device.value2)}");
  }
}
