import 'package:Sterilizer/model/data.dart';
import 'package:flutter/material.dart';

import 'change_wifi.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 30, bottom: 30),
          child: ListTile(
            title: Text(
              "Settings",
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
              Icons.home_rounded,
              color: Colors.black,
            ),
            title: Text(homeName),
            subtitle: Text("Edit your home name"),
            onTap: () {},
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
            title: Text('Connect device to Wifi'),
            onTap: () {
              resetHomeWifi();
            },
          ),
        ),
      ],
    );
  }

  resetHomeWifi() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ChangeWifi()));
  }
}
