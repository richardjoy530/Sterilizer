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
                    device.motionReset();
                    Navigator.pop(context);
                  }),
            ),
          )
        ],
      );
    },
  );
}