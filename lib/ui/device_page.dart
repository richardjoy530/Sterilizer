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

  bool uv = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  get device => widget.device;

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
                "Sterilizer $userId",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Listener(
                onPointerDown: (event) {
                  setState(() {
                    anim = "hold";
                  });
                  timer = Timer.periodic(Duration(seconds: 1), (value) {
                    if (anim == "hold") device.toggleMode();
                    anim = "idle";
                  });
                },
                onPointerUp: (event) {
                  timer.cancel();
                  setState(() {
                    anim = "idle";
                  });
                },
                child: Container(
                  width: 200,
                  height: 200,
                  child: FlareActor("assets/mode2.flr",
                      alignment: Alignment.center,
                      fit: BoxFit.contain,
                      animation: anim),
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
                        animation: uv == true ? "on" : "off"),
                  ),
                  onTap: () {
                    setState(() {
                      uv = !uv;
                      device.switchUV(uv);
                    });
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
