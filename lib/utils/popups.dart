import 'package:Sterilizer/model/data.dart';
import 'package:flutter/material.dart';

motionDetectedPopUp(Device device) async {
  await showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return SimpleDialog(
        backgroundColor: Color(0xffe8e8e8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Motion Detected',
          textAlign: TextAlign.center,
        ),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.dangerous),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Your device has been stopped"),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Color(0xff060606),
                  child: Text(
                    "Ok",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    device.resetMotion();
                    Navigator.pop(context);
                  }),
            ),
          )
        ],
      );
    },
  );
}

Future<bool> deleteSchedulePopup() async {
  bool result = false;
  await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Deleting Schedule',
            textAlign: TextAlign.center,
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: Text("Are you sure ?")),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Color(0xff060606),
                      child: Text(
                        "Yes",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        result = true;
                      }),
                  RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.white,
                      child: Text(
                        "No",
                        style: TextStyle(color: Color(0xff060606)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        result = false;
                      }),
                ],
              ),
            )
          ],
        );
      });
  return result;
}

enterPasswordPopUp() async {
  TextEditingController passwordController = TextEditingController();
  TextEditingController idController = TextEditingController();
  await showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return SimpleDialog(
        backgroundColor: Color(0xffe8e8e8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Enter your wifi password',
          textAlign: TextAlign.center,
        ),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.wifi_lock_rounded),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(homeSSID),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: TextField(
              cursorColor: Colors.black,
              decoration: InputDecoration(
                labelText: "Password",
                focusColor: Colors.black,
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: Colors.black,
                    style: BorderStyle.solid,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: Colors.black,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
              controller: passwordController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: TextField(
              keyboardType: TextInputType.number,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                labelText: "Device ID",
                focusColor: Colors.black,
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: Colors.black,
                    style: BorderStyle.solid,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: Colors.black,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
              controller: idController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Color(0xff060606),
                  child: Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    prefs.setString('homePass', passwordController.text);
                    prefs.setString("homeSSID", homeSSID);
                    prefs.setInt("deviceID", int.parse(idController.text));
                    deviceIdTemp = int.parse(idController.text);
                    homePass = passwordController.text;
                    Navigator.pop(context);
                  }),
            ),
          )
        ],
      );
    },
  );
}
