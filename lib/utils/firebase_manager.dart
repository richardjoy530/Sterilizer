import 'package:Sterilizer/model/data.dart';
import 'package:firebase_database/firebase_database.dart';

String localStates = "";

class FirebaseManager {
  DatabaseReference db;

  FirebaseManager() {
    db = FirebaseDatabase.instance.reference();
  }

  add() {
    db.child(userId).child("mode").set(-1);
    db.child(userId).child("uv").set("OFF");
  }

  Future<void> setMode(int mode) async {
    db.child(userId).child("mode").set(mode);
  }

  switchUV(bool uv) async {
    if (uv)
      db.child(userId).child("uv").set("ON");
    else
      db.child(userId).child("uv").set("OFF");
  }
}
