import 'dart:async';
import 'dart:io';

import 'package:Sterilizer/ui/device_page.dart';
import 'package:Sterilizer/ui/registration_process.dart';
import 'package:flutter/material.dart';
import 'package:wifi/wifi.dart';

import '../model/data.dart';
import 'dashboard_container.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void Function(void Function()) setBottomSheetState;

  @override
  void initState() {
    Device.setHomePageState(() {
      setState(() {});
    });
    contextStack.add(this.context);
    super.initState();
  }

  @override
  void dispose() {
    serverSocket?.close();
    contextStack.remove(this.context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: General(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            onAddDevicePressed();
          },
          label: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.add),
              Text("Add Device"),
            ],
          ),
        ),
      ),
    );
  }

  onAddDevicePressed() async {
    deviceIdTemp = -1;
    RegistrationProcess.currentStatus = 0;
    RegistrationProcess.currentStatusString = RegistrationProcess.PREPARING;
    var choice = await choseAddOption();
    if (choice == AddDeviceChoice.ExistingDevice)
      await addExistingDevice();
    else if (choice == AddDeviceChoice.NewDevice) await addDevicePopup();
    if (deviceIdTemp != -1 && deviceNameTemp != "") await showBottomSheet();
  }

  addDevicePopup() async {
    TextEditingController passwordController =
        TextEditingController(text: homePass);
    TextEditingController idController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    homeSSID = await Wifi.ssid;
    await showDialog(
      barrierDismissible: false,
      context: this.context,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
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
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              child: TextField(
                cursorColor: Colors.black,
                keyboardType: TextInputType.number,
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
                      "Connect",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      homePass = passwordController.text;
                      deviceIdTemp = int.parse(idController.text);
                      deviceNameTemp = nameController.text;
                      idController.text = "";
                      nameController.text = "";
                      Navigator.pop(context);
                    }),
              ),
            )
          ],
        );
      },
    );
  }

  showBottomSheet() async {
    await showModalBottomSheet(
        backgroundColor: Colors.white,
        enableDrag: false,
        isDismissible: false,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        ),
        builder: (context) {
          return RegistrationProcessWidgets();
        });
  }

  addExistingDevice() async {
    TextEditingController idController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    homeSSID = await Wifi.ssid;
    await showDialog(
      barrierDismissible: false,
      context: this.context,
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
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              child: TextField(
                cursorColor: Colors.black,
                keyboardType: TextInputType.number,
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
                      "Connect",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      deviceIdTemp = int.parse(idController.text);
                      deviceNameTemp = nameController.text;
                      idController.text = "";
                      nameController.text = "";
                      var device = Device.fromFire(
                          name: deviceNameTemp, id: deviceIdTemp);
                      setState(() {
                        deviceList.add(device);
                      });
                      deviceIdTemp = -1;
                      deviceNameTemp = "";
                      Navigator.pop(context);
                    }),
              ),
            )
          ],
        );
      },
    );
  }

  Future<AddDeviceChoice> choseAddOption() async {
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
}