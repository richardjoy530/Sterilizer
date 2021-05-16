import 'package:Sterilizer/model/data.dart';
import 'package:flutter/material.dart';

import 'device_page.dart';

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
                          trailing: Icon(Icons.arrow_forward_ios_rounded),
                          title: Text(deviceList[index].name),
                          subtitle: Text(deviceList[index].connectedWifi),
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
