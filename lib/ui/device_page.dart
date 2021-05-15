import 'dart:async';

import 'package:Sterilizer/model/data.dart';
import 'package:Sterilizer/ui/schedule_page.dart';
import 'package:Sterilizer/utils/popups.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'change_wifi.dart';

class DevicePage extends StatefulWidget {
  final Device device;

  DevicePage(this.device);

  @override
  _DevicePageState createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  String toggle = "idleOn";
  Timer timer;

  @override
  void initState() {
    super.initState();
    toggle = device.uv == true ? "idleOn" : "idleOff";
    contextStack.add(this.context);
    device.setDevicePageState(() {
      setState(() {
        toggle = "toggleOff";
      });
    });
  }

  @override
  void dispose() {
    print("DevicePage disposed");
    timer?.cancel();
    contextStack.remove(this.context);
    super.dispose();
  }

  Device get device => widget.device;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ListView(
          children: [
            Container(
              margin: EdgeInsets.only(top: 30, bottom: 12),
              child: ListTile(
                title: Text(
                  device.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25),
                ),
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.wifi_lock_rounded),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(device.connectedWifi),
                  )
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading: Icon(
                      Icons.wb_twighlight,
                      color: Colors.black,
                    ),
                    title: Text('Enable UV'),
                    subtitle: Text("Tap to enable disinfection with UV"),
                    trailing: Container(
                      width: 60,
                      child: FlareActor("assets/Toggle.flr",
                          alignment: Alignment.center,
                          fit: BoxFit.contain,
                          animation: toggle),
                    ),
                    onTap: () {
                      setState(() {
                        device.uv = !device.uv;
                        device.updateDevice();
                        toggle = device.uv == true ? "toggleOn" : "toggleOff";
                      });
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),
                  margin: EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.schedule_rounded,
                        color: Colors.black,
                      ),
                      title: Text('Set schedules'),
                      subtitle: Text(
                          "Automate your steriliser by setting multiple schedules"),
                      trailing: Container(
                        width: 60,
                        height: 60,
                        child: Icon(Icons.arrow_forward_ios_rounded),
                      ),
                      onTap: () {
                        setState(() {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SchedulePage(device)));
                        });
                      },
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),
                  margin: EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.wifi_rounded,
                        color: Colors.black,
                      ),
                      title: Text('Change Wifi'),
                      subtitle:
                          Text("Change the connected Wifi of this device"),
                      trailing: Container(
                        width: 60,
                        height: 60,
                        child: Icon(Icons.arrow_forward_ios_rounded),
                      ),
                      onTap: () {
                        setState(() {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChangeWifi(device)));
                        });
                      },
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),
                  margin: EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.edit_rounded,
                        color: Colors.black,
                      ),
                      title: Text('Rename device'),
                      onTap: () {
                        setState(() {
                          renameDevicePopUp(device);
                        });
                      },
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),
                  margin: EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.delete_outline_outlined,
                        color: Colors.black,
                      ),
                      title: Text('Remove device'),
                      onTap: () {
                        setState(() {
                          device.deleteDevice();
                          deviceList.remove(device);
                          Device.homePageSetState.call();
                          Navigator.pop(context);
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(device.id.toString(),style: TextStyle(color: Colors.black12),),
              ),
            )
          ],
        ),
      ),
    );
  }
}
