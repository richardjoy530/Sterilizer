import 'package:Sterilizer/model/data.dart';
import 'package:Sterilizer/utils/popups.dart';
import 'package:firebase_database/firebase_database.dart';

String localStates = "";

class FirebaseManager {
  static DatabaseReference db = FirebaseDatabase.instance.reference();

  static add(Device device) {
    db.child(device.id.toString()).child("motionDetected").set(1);
    db.child(device.id.toString()).child("uv").set("OFF");
  }

  static updateUV(Device device) async {
    if (device.uv)
      db.child(device.id.toString()).child("uv").set("ON");
    else
      db.child(device.id.toString()).child("uv").set("OFF");
  }

  static sync(Device device) {
    db
        .child(device.id.toString())
        .child("uv")
        .once()
        .then((value) => device.uv = value.value == "OFF" ? false : true);
    // Checking if motion was detected previously and machine was stopped.
    db.child(device.id.toString()).child("motionDetected").once().then((value) {
      if (value.value == 2) motionDetectedPopUp(device);
    });

    return device;
  }

  static updateSchedules(Device device) {
    List<Map<String, dynamic>> mapList = [];
    device.schedules.forEach((element) {
      var start =
          element.startTime.hour * 60 * 60 + element.startTime.minute * 60;
      var end = element.endTime.hour * 60 * 60 + element.endTime.minute * 60;
      if (element.state)
        mapList.add({
          "endStamp": end,
          "startStamp": start,
          "dayStamp": encodeScheduleDays(element),
        });
    });
    db.child(device.id.toString()).child("schedules").set(mapList);
    db
        .child(device.id.toString())
        .child("schedules")
        .child('active')
        .set(mapList.length);
  }

  static void motionReset(Device device) {
    db.child(device.id.toString()).child("motionDetected").set(1);
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
}
