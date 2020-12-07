import 'package:Sterilizer/model/data.dart';
import 'package:firebase_database/firebase_database.dart';

String localStates = "";

class FirebaseManager {
  DatabaseReference db;

  FirebaseManager() {
    db = FirebaseDatabase.instance.reference();
  }

  add(int id) {
    db.child(id.toString()).child("motionDetected").set(1);
    db.child(id.toString()).child("uv").set("OFF");
    db.child(id.toString()).child("appConnected").set(1);
  }

  switchUV(int id, bool uv) async {
    if (uv)
      db.child(id.toString()).child("uv").set("ON");
    else
      db.child(id.toString()).child("uv").set("OFF");
  }

  sync(Device device) {
    db
        .child(device.id.toString())
        .child("uv")
        .once()
        .then((value) => device.uv = value.value=="OFF"?false:true);
    return device;
  }
}
