import 'dart:async';
import 'dart:io';

import 'package:Sterilizer/model/data.dart';
import 'package:flutter/material.dart';
import 'package:wifi/wifi.dart';

class ChangeWifi extends StatefulWidget {
  final Device device;

  ChangeWifi(this.device);

  @override
  _ChangeWifiState createState() => _ChangeWifiState();
}

class _ChangeWifiState extends State<ChangeWifi> {
  Device get device => widget.device;

  TextEditingController passwordController;
  String tempSSID;
  Timer _timer;

  void Function(void Function()) setBottomSheetState;

  @override
  void initState() {
    tempSSID = "New Wifi";
    contextStack.add(this.context);
    passwordController = TextEditingController();
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      Wifi.ssid.then((value) => setState(() => tempSSID = value));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    contextStack.remove(this.context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              margin: EdgeInsets.only(top: 30, bottom: 30),
              child: ListTile(
                title: Text(
                  "Change your device Wifi",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25),
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(15.0),
            //   child: Center(
            //     child:
            //         CircularProgressIndicator(backgroundColor: Colors.black12),
            //   ),
            // ),
            Container(
              child: ListTile(
                title: Text(
                  "Make sure your phone is connected to the new wifi",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.wifi_lock_rounded),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(tempSSID),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: TextField(
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      labelText: "Enter Wifi Password",
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
                      "Connect",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if(passwordController.text!=""){
                        homePass = passwordController.text;
                        homeSSID = tempSSID;
                        RegistrationProcess.currentStatus = 0;
                        RegistrationProcess.currentStatusString =
                            RegistrationProcess.PREPARING;
                        await showBottomSheet();
                        if (contextStack.last.widget.runtimeType == BottomSheet)
                          contextStack.removeLast();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }

  bool ack = false;

  Future<void> connectToServer() async {
    ack = false;
    serverSocket?.close();
    serverSocket = await ServerSocket.bind("0.0.0.0", 5555);
    serverSocket.listen((event) {
      sendCredentials(event);
    });
    while (ack == false) {
      print("Waiting for acknowledgment");
      await Future.delayed(Duration(seconds: 1));
    }
  }

  sendCredentials(Socket data) {
    print(homeSSID);
    print(homePass);
    data.write(homeSSID + "\r");
    data.write(homePass + "\r");
    ack = true;
    data?.close();
    serverSocket?.close();
    // data.listen((event) async {
    //   print(String.fromCharCodes(event));
    //   if (String.fromCharCodes(event)[0] == '1') {
    //     final Map<String, dynamic> cred = {
    //       'ssid': homeSSID,
    //       'password': homePass,
    //     };
    //     platform.invokeMethod("connectHome", cred);
    //
    //     data?.close();
    //     serverSocket?.close();
    //   }
    // });
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
        builder: (contextPopUp) {
          if (!contextStack.contains(contextPopUp)) {
            contextStack.add(contextPopUp);
            startRegistrationProcess();
          }
          return StatefulBuilder(builder: (context, setStateOfBottomSheet) {
            setBottomSheetState = setStateOfBottomSheet;
            return bottomSheetWidgets();
          });
        });
  }

  startRegistrationProcess() async {
    await Future.delayed(Duration(seconds: 1));
    if (contextStack.last.widget.runtimeType == BottomSheet)
      await changeRegistrationStatus(
          RegistrationProcess.PREPARING, setBottomSheetState);
    Map<String, dynamic> cred = {
      'ssid': DEVICE_SSID,
      'password': DEVICE_PASSWORD,
    };

    if (contextStack.last.widget.runtimeType == BottomSheet)
      await changeRegistrationStatus(
          RegistrationProcess.SEARCHING, setBottomSheetState);
    await platform.invokeMethod("register", cred);

    if (contextStack.last.widget.runtimeType == BottomSheet)
      await changeRegistrationStatus(
          RegistrationProcess.ESTABLISHING, setBottomSheetState);
    String ssid = await Wifi.ssid;
    while (ssid != DEVICE_SSID) {
      ssid = await Wifi.ssid;
    }

    if (contextStack.last.widget.runtimeType == BottomSheet)
      await changeRegistrationStatus(
          RegistrationProcess.REGISTERING, setBottomSheetState);
    await connectToServer();
    await Future.delayed(Duration(seconds: 5));

    if (contextStack.last.widget.runtimeType == BottomSheet)
      await changeRegistrationStatus(
          RegistrationProcess.WAITING, setBottomSheetState);

    if (contextStack.last.widget.runtimeType == BottomSheet)
      await changeRegistrationStatus(
          RegistrationProcess.FINISHING, setBottomSheetState);

    if (contextStack.last.widget.runtimeType == BottomSheet)
      await changeRegistrationStatus(
          RegistrationProcess.OVER, setBottomSheetState);
    device.connectedWifi=homeSSID;
    device.isWifiDirty=true;
    device.updateDevice();
    if (contextStack.last.widget.runtimeType == BottomSheet)
      await Future.delayed(Duration(milliseconds: 1000));

    if (contextStack.last.widget.runtimeType == BottomSheet)
      Navigator.pop(contextStack.removeLast());
    setBottomSheetState = null;
  }

  changeRegistrationStatus(
      String status, Function(void Function()) setStateOfBottomSheet) async {
    await Future.delayed(Duration(milliseconds: 500));
    if (contextStack.last.widget.runtimeType == BottomSheet)
      setStateOfBottomSheet(() {
        RegistrationProcess.changeStatus(status);
      });
  }

  Widget bottomSheetWidgets() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: <Widget>[
        Divider(
          thickness: 2,
          color: Colors.black,
          indent: 2 * MediaQuery.of(context).size.width / 4,
          endIndent: 2 * MediaQuery.of(context).size.width / 4,
        ),
        Container(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                child: SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                        backgroundColor: Colors.black12, strokeWidth: 2)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  RegistrationProcess.currentStatusString,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                ),
              ),
            ],
          ),
        ),
        Container(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      RegistrationProcess.currentStatus > 0
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: Colors.black,
                      size: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(RegistrationProcess.PREPARING),
                    )
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      RegistrationProcess.currentStatus > 1
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: Colors.black,
                      size: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(RegistrationProcess.SEARCHING),
                    )
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      RegistrationProcess.currentStatus > 2
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: Colors.black,
                      size: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(RegistrationProcess.ESTABLISHING),
                    )
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      RegistrationProcess.currentStatus > 3
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: Colors.black,
                      size: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(RegistrationProcess.REGISTERING),
                    )
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      RegistrationProcess.currentStatus > 4
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: Colors.black,
                      size: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(RegistrationProcess.WAITING),
                    )
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      RegistrationProcess.currentStatus > 5
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: Colors.black,
                      size: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(RegistrationProcess.FINISHING),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Divider(
          thickness: 2,
          color: Colors.black,
          indent: 2 * MediaQuery.of(context).size.width / 4,
          endIndent: 2 * MediaQuery.of(context).size.width / 4,
        )
      ],
    );
  }
}
