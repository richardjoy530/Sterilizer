import 'package:Sterilizer/model/data.dart';
import 'package:flutter/material.dart';
import 'package:wifi/wifi.dart';

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

renameDevicePopUp(Device device) async {
  TextEditingController nameController = TextEditingController();
  await showDialog(
    barrierDismissible: false,
    context: context,
    builder: (contextPopUp) {
      contextStack.add(contextPopUp);
      return SimpleDialog(
        backgroundColor: Color(0xffe8e8e8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Rename Device',
          textAlign: TextAlign.center,
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
            child: TextField(
              cursorColor: Colors.black,
              decoration: InputDecoration(
                labelText: "Name your Device",
                focusColor: Colors.black,
                labelStyle: TextStyle(color: Colors.black),
                border: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: Colors.black,
                    style: BorderStyle.solid,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: Colors.black,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
              controller: nameController,
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
                    device.name = nameController.text;
                    device.isNameDirty = true;
                    device.updateDevice();
                    Navigator.pop(contextStack.removeLast());
                  }),
            ),
          )
        ],
      );
    },
  );
  if (contextStack.last.widget.runtimeType == Builder)
    contextStack.removeLast();
}

addDevicePopup() async {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController passwordController =
      TextEditingController(text: homePass);
  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  homeSSID = await Wifi.ssid;
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
          'Add new device',
          textAlign: TextAlign.center,
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Text(
              "Make sure your phone is connected to Wifi where Sterilizer will be connected",
              textAlign: TextAlign.center,
            ),
          ),
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
          Form(
            key: formKey,
              child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) return "Password Required";
                    return null;
                  },
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    labelText: "Wifi Password",
                    focusColor: Colors.black,
                    labelStyle: TextStyle(color: Colors.black),
                    border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Colors.black,
                        style: BorderStyle.solid,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) return "ID Required";
                    return null;
                  },
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    labelText: "Enter your Device ID",
                    focusColor: Colors.black,
                    labelStyle: TextStyle(color: Colors.black),
                    border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Colors.black,
                        style: BorderStyle.solid,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) return "Name Required";
                    return null;
                  },
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    labelText: "Name your Device",
                    focusColor: Colors.black,
                    labelStyle: TextStyle(color: Colors.black),
                    border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Colors.black,
                        style: BorderStyle.solid,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Colors.black,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                  controller: nameController,
                ),
              ),
            ],
          )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Color(0xff060606),
                  child: Text(
                    "Connect",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (formKey.currentState.validate()) {
                      homePass = passwordController.text;
                      deviceIdTemp = int.parse(idController.text);
                      deviceNameTemp = nameController.text;
                      idController.text = "";
                      nameController.text = "";
                      Navigator.pop(context);
                    }
                  }),
            ),
          )
        ],
      );
    },
  );
}

addExistingDevicePopUp() async {
  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  homeSSID = await Wifi.ssid;
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
          'Add new device',
          textAlign: TextAlign.center,
        ),
        children: <Widget>[
          Form(
              key: formKey,
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                    child: TextFormField(
                      validator: (value) {
                        if (value.isEmpty) return "ID Required";
                        return null;
                      },
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        labelText: "Enter your Device ID",
                        focusColor: Colors.black,
                        labelStyle: TextStyle(color: Colors.black),
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Colors.black,
                            style: BorderStyle.solid,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                    child: TextFormField(
                      validator: (value) {
                        if (value.isEmpty) return "Name Required";
                        return null;
                      },
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        labelText: "Name your Device",
                        focusColor: Colors.black,
                        labelStyle: TextStyle(color: Colors.black),
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Colors.black,
                            style: BorderStyle.solid,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Colors.black,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                      controller: nameController,
                    ),
                  ),
                ],
              )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Color(0xff060606),
                  child: Text(
                    "Connect",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (formKey.currentState.validate()) {
                      deviceIdTemp = int.parse(idController.text);
                      deviceNameTemp = nameController.text;
                      idController.text = "";
                      nameController.text = "";
                      var device = Device.fromFire(
                          name: deviceNameTemp, id: deviceIdTemp);
                      deviceList.add(device);
                      deviceIdTemp = -1;
                      deviceNameTemp = "";
                      Navigator.pop(context);
                    }
                  }),
            ),
          )
        ],
      );
    },
  );
}

Future<AddDeviceChoice> choseAddOptionPopUp() async {
  AddDeviceChoice choice = AddDeviceChoice.Invalid;
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
            'New device ?',
            textAlign: TextAlign.center,
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                  child: Text(
                "Do you want to register a new device or add an existing device?",
                textAlign: TextAlign.center,
              )),
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
                        "New",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        choice = AddDeviceChoice.NewDevice;
                      }),
                  RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.white,
                      child: Text(
                        "Existing",
                        style: TextStyle(color: Color(0xff060606)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        choice = AddDeviceChoice.ExistingDevice;
                      }),
                ],
              ),
            )
          ],
        );
      });
  return choice;
}
