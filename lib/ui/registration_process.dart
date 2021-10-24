import 'dart:io';

import 'package:Sterilizer/model/data.dart';
import 'package:flutter/material.dart';
import 'package:wifi/wifi.dart';
import 'package:app_settings/app_settings.dart';

class RegistrationProcessWidgets extends StatefulWidget {
  final bool newDevice;
  final Device device;

  const RegistrationProcessWidgets(this.newDevice, {this.device, Key key})
      : super(key: key);

  @override
  _RegistrationProcessWidgetsState createState() =>
      _RegistrationProcessWidgetsState();
}

class _RegistrationProcessWidgetsState
    extends State<RegistrationProcessWidgets> {
  bool ack = false;

  Device get device => widget.device;

  @override
  void initState() {
    startRegistrationProcess();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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

  startRegistrationProcess() async {
    await changeRegistrationStatus(RegistrationProcess.PREPARING);
    Map<String, dynamic> cred = {
      'ssid': DEVICE_SSID,
      'password': DEVICE_PASSWORD,
    };

    await changeRegistrationStatus(RegistrationProcess.SEARCHING);
    // await plat/form.invokeMethod("register", cred);
    print("to settings");

    await AppSettings.openWIFISettings();

    print("back from settings");

    await changeRegistrationStatus(RegistrationProcess.ESTABLISHING);
    String ssid = await Wifi.ssid;
    while (ssid != DEVICE_SSID) ssid = await Wifi.ssid;

    await changeRegistrationStatus(RegistrationProcess.REGISTERING);
    await connectToTCPServer();
    await Future.delayed(Duration(seconds: 3));

    await changeRegistrationStatus(RegistrationProcess.WAITING);

    await changeRegistrationStatus(RegistrationProcess.FINISHING);
    if (mounted) {
      if (widget.newDevice) {
        var device = Device.newDevice(
            name: deviceNameTemp, id: deviceIdTemp, connectedWifi: homeSSID);
        setState(() {
          deviceList.add(device);
          Device.homePageSetState?.call();
        });
      } else {
        device.connectedWifi = homeSSID;
        device.isWifiDirty = true;
        device.updateDevice();
      }
    }

    await changeRegistrationStatus(RegistrationProcess.OVER);
    await Future.delayed(Duration(milliseconds: 500));
    Navigator.pop(context);
  }

  changeRegistrationStatus(String status) async {
    await Future.delayed(Duration(milliseconds: 500));
    if (mounted)
      setState(() {
        RegistrationProcess.changeStatus(status);
      });
  }

  Future<void> connectToTCPServer() async {
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
  }
}
