import 'package:Sterilizer/model/data.dart';
import 'package:firebase_database/firebase_database.dart';
List<dynamic> localStates = [];
class FirebaseManager {
  DatabaseReference db;

  FirebaseManager() {
    db = FirebaseDatabase.instance.reference();
  }

  add(Map map,String name) {
    db.child(userId).child(name).set(map);
  }

  Future<void> addToggles() async {
    var state= await db.reference().child(userId).child("state").once();
    if(state.value==null){
      List<dynamic> states = [1];
      db.child(userId).child("state").set(states);
    }
    else{
      List<dynamic> fireStates = state.value;
      localStates.add(1);
      localStates.addAll(fireStates);
      db.child(userId).child("state").set(localStates).then((value) {
        localStates=[];
        return;
      });
    }
  }

}
