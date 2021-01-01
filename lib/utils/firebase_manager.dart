import 'package:Sterilizer/model/data.dart';
import 'package:firebase_database/firebase_database.dart';

String localStates = "";

class FirebaseManager {
  DatabaseReference db;

  FirebaseManager() {
    db = FirebaseDatabase.instance.reference();
  }

  add(Device device) {
    db.child(device.id.toString()).child("motionDetected").set(1);
    db.child(device.id.toString()).child("uv").set("OFF");
    db.child(device.id.toString()).child("appConnected").set(1);
  }

  switchUV(Device device) async {
    if (device.uv)
      db.child(device.id.toString()).child("uv").set("ON");
    else
      db.child(device.id.toString()).child("uv").set("OFF");
  }

  sync(Device device) {
    db
        .child(device.id.toString())
        .child("uv")
        .once()
        .then((value) => device.uv = value.value == "OFF" ? false : true);
    return device;
  }

  updateSchedules(Device device) {
    List<Map<String, dynamic>> mapList = [];
    device.schedules.forEach((element) {
      var start =
          element.startTime.hour * 60 * 60 + element.startTime.minute * 60;
      var end = element.endTime.hour * 60 * 60 + element.endTime.hour * 60;
      var temp = element.stringify().split(" ");
      mapList.add({
        "state": element.state ? 1 : 0,
        "endStamp": end,
        "startStamp": start,
        "Sunday": temp[4 + 1],
        "Monday": temp[4 + 2],
        "Tuesday": temp[4 + 3],
        "Wednesday": temp[4 + 4],
        "Thursday": temp[4 + 5],
        "Friday": temp[4 + 6],
        "Saturday": temp[4 + 7],
      });
    });
    db.child(device.id.toString()).child("schedules").set(mapList);
  }

  void motionReset(Device device) {
    db.child(device.id.toString()).child("motionDetected").set(1);
  }
}
