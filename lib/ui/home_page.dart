import 'dart:io';

import 'package:Sterilizer/ui/device_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wifi/wifi.dart';

import '../model/data.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void Function(void Function()) setBottomSheetState;

  @override
  void initState() {
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
    return Scaffold(
      body: General(),
      floatingActionButton: Visibility(
        child: FloatingActionButton.extended(
          onPressed: () {
            onAddDevicePressed(context);
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

  void connectToServer() {
    serverSocket?.close();
    ServerSocket.bind("0.0.0.0", 5555).then((value) {
      serverSocket = value;
      value.listen((event) {}).onData((data) => sendCredentials(data));
    });
  }

  sendCredentials(Socket data) {
    print(homeSSID);
    print(homePass);
    data.write(homeSSID + "\r");
    data.write(homePass + "\r");
    data.listen((event) async {
      print(String.fromCharCodes(event));
      if (String.fromCharCodes(event)[0] == '1') {
        final Map<String, dynamic> cred = {
          'ssid': homeSSID,
          'password': homePass,
        };
        platform.invokeMethod("connectHome", cred);
        Wifi.connection(homeSSID, homePass);
        data?.close();
        serverSocket?.close();
      }
    });
  }

  onAddDevicePressed(BuildContext context) async {
    RegistrationProcess.currentStatus = 0;
    RegistrationProcess.currentStatusString = RegistrationProcess.PREPARING;
    await addDevicePopup();
    if (deviceIdTemp != -1 && deviceNameTemp != "") await showBottomSheet();
    if (contextStack.last.widget.runtimeType == BottomSheet)
      contextStack.removeLast();
    deviceIdTemp = -1;
  }

  startRegistrationProcess() async {
    await Future.delayed(Duration(seconds: 1));

    await changeRegistrationStatus(
        RegistrationProcess.PREPARING, setBottomSheetState);
    final Map<String, dynamic> cred = {
      'ssid': DEVICE_SSID,
      'password': DEVICE_PASSWORD,
    };

    await changeRegistrationStatus(
        RegistrationProcess.SEARCHING, setBottomSheetState);
    // await platform.invokeMethod("register", cred);

    await changeRegistrationStatus(
        RegistrationProcess.ESTABLISHING, setBottomSheetState);
    String ssid = await Wifi.ssid;
    // while (ssid != DEVICE_SSID) {
    //   ssid = await Wifi.ssid;
    // }

    await changeRegistrationStatus(
        RegistrationProcess.REGISTERING, setBottomSheetState);
    // connectToServer();

    await changeRegistrationStatus(
        RegistrationProcess.WAITING, setBottomSheetState);

    await changeRegistrationStatus(
        RegistrationProcess.FINISHING, setBottomSheetState);
    var device = Device.newDevice(name: deviceNameTemp, id: deviceIdTemp);
    setState(() {
      deviceList.add(device);
    });

    await changeRegistrationStatus(
        RegistrationProcess.OVER, setBottomSheetState);
    await Future.delayed(Duration(milliseconds: 500));
    if (contextStack.last.widget.runtimeType == BottomSheet)
      Navigator.pop(contextStack.removeLast());
  }

  changeRegistrationStatus(
      String status, Function(void Function()) setStateOfBottomSheet) async {
    await Future.delayed(Duration(milliseconds: 500));
    if (contextStack.last.widget.runtimeType == BottomSheet)
      setStateOfBottomSheet(() {
        RegistrationProcess.changeStatus(status);
      });
  }

  addDevicePopup() async {
    TextEditingController passwordController = TextEditingController();
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

class General extends StatefulWidget {
  @override
  _GeneralState createState() => _GeneralState();
}

class _GeneralState extends State<General> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 30, bottom: 30),
          child: ListTile(
            title: Text(
              homeName,
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0)),
                ),
                child: ListView.builder(
                    itemCount: deviceList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                        margin: EdgeInsets.all(10),
                        child: ListTile(
                          leading: Icon(
                            Icons.wifi_tethering_rounded,
                            color: Colors.black,
                          ),
                          title:
                              Text(deviceList[index].name),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        DevicePage(deviceList[index])));
                          },
                        ),
                      );
                    })),
          ),
        )
      ],
    );
  }
}
