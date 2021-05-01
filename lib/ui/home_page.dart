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
  TextEditingController passwordController;
  String floatingButtonText = "Add Device";

  TextEditingController idController;

  @override
  void initState() {
    contextStack.add(this.context);
    passwordController = TextEditingController();
    idController = TextEditingController();
    load();
    super.initState();
  }

  @override
  void dispose() {
    passwordController.dispose();
    idController.dispose();
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
            onMenuPressed(context);
          },
          label: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.add),
              Text(floatingButtonText),
            ],
          ),
        ),
      ),
    );
  }

  resetHomeWifi() async {
    prefs.remove('homePass');
    prefs.remove('homeSSID');
    prefs.remove('homeIP');
    homeSSID = await Wifi.ssid;
    load();
  }

  load() async {
    String pass = prefs.getString('homePass');
    if (pass == null) {
      Future.delayed(Duration(seconds: 1)).then((value) {
        enterPasswordPopUp();
      });
    }
  }

  enterPasswordPopUp() async {
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
                      deviceId = int.parse(idController.text);
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

  wifiConnect(String ssid, String password) async {
    final Map<String, dynamic> cred = {
      'ssid': ssid,
      'password': password,
    };
    return await platform.invokeMethod("wifi", cred);
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

  onMenuPressed(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        ),
        builder: (context) {
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
                child: Text(
                  "Searching for devices",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
                margin: EdgeInsets.all(10),
                child: ListTile(
                  leading: Icon(
                    Icons.wifi_tethering_rounded,
                    color: Colors.black,
                  ),
                  title: Text('Ibis Sterilizer'),
                  subtitle: Text("Tap to connect"),
                  onTap: () {
                    addDevice();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Center(
                  child: CircularProgressIndicator(
                      backgroundColor: Colors.black12),
                ),
              ),
            ],
          );
        });
  }

  addDevice() async {
    var device = Device(name: "Purifier", uv: false);
    setState(() {
      deviceList.add(device);
    });
    print(homeSSID);
    print(homePass);
    final Map<String, dynamic> cred = {
      'ssid': DEVICE_SSID,
      'password': DEVICE_PASSWORD,
    };
    var result = await platform.invokeMethod("register", cred);
    print(result.runtimeType);
    String ssid = await Wifi.ssid;
    while (ssid != DEVICE_SSID) {
      ssid = await Wifi.ssid;
    }
    print(ssid);
    connectToServer();
  }

  addDevicePopup() async {
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
              padding: const EdgeInsets.symmetric(horizontal: 40),
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

  addNewSchedule() {
    if (deviceList.isNotEmpty) if (deviceList[0].schedules.length < 5)
      setState(() {
        deviceList[0].schedules.add(ScheduleData(
            TimeOfDay(hour: 6, minute: 15),
            TimeOfDay(hour: 7, minute: 15),
            false,
            [false, false, false, false, false, false, false]));
      });
    else
      Fluttertoast.showToast(
        msg: "Cannot add more than 5 schedules",
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
                              Text('Ibis Sterilizer ${deviceList[index].name}'),
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
