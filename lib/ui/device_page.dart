import 'package:Sterilizer/model/data.dart';
import 'package:Sterilizer/ui/schedule_page.dart';
import 'package:Sterilizer/ui/widgets.dart';
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
                genericTile(
                    text: 'Enable UV',
                    subTitle: "Tap to enable disinfection with UV",
                    leadingIcon: Icons.wb_twighlight,
                    trailing: FlareActor("assets/Toggle.flr",
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                        animation: toggle),
                    onTap: () {
                      setState(() {
                        device.uv = !device.uv;
                        device.isUVDirty=true;
                        device.updateDevice();
                        toggle = device.uv == true ? "toggleOn" : "toggleOff";
                      });
                    }),
                genericTile(
                    text: 'Set schedules',
                    subTitle:
                        "Automate your steriliser by setting multiple schedules",
                    leadingIcon: Icons.schedule_rounded,
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                      setState(() {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SchedulePage(device)));
                      });
                    }),
                genericTile(
                    text: 'Change Wifi',
                    subTitle: "Change the connected Wifi of this device",
                    leadingIcon: Icons.wifi_rounded,
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                      setState(() {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChangeWifi(device)));
                      });
                    }),
                genericTile(
                    text: 'Rename device',
                    leadingIcon: Icons.edit_rounded,
                    onTap: () {
                      setState(() {
                        renameDevicePopUp(device);
                      });
                    }),
                genericTile(
                    text: 'Remove device',
                    leadingIcon: Icons.delete_outline_outlined,
                    onTap: () {
                      setState(() {
                        device.deleteDevice();
                        deviceList.remove(device);
                        Device.homePageSetState?.call();
                        Navigator.pop(context);
                      });
                    }),
              ],
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  device.id.toString(),
                  style: TextStyle(color: Colors.black12),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
