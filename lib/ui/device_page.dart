import 'dart:async';

import 'package:flare_flutter/flare_actor.dart';

import 'package:Sterilizer/model/data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DevicePage extends StatefulWidget {
  final Device device;

  DevicePage(this.device);

  @override
  _DevicePageState createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  String anim = "idle";
  Timer timer;

  @override
  void initState() {
    super.initState();
    context = this.context;
    device.setTheState((){ setState(() {
    }); });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  Device get device => widget.device;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            margin: EdgeInsets.only(top: 30, bottom: 30),
            child: ListTile(
              title: Text(
                "Sterilizer ${device.name}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25),
              ),
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
                    animation: device.uv == true ? "on" : "off"),
              ),
              onTap: () {
                setState(() {
                  device.uv = !device.uv;
                  device.switchUV(device.uv);
                });
              },
            ),
          )
        ],
      ),
    );
  }
}
