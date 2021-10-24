import 'package:Sterilizer/model/data.dart';
import 'package:Sterilizer/ui/widgets.dart';
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
          margin: 
                    EdgeInsets.only(top: 30, bottom: 30, left: 50, right: 50),
          child: ListTile(
              title: Image.asset(
            'assets/logo.png',
            // color: Color(0xff00477d),
          )),
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
                      return genericTile(
                          text: deviceList[index].name,
                          subTitle: deviceList[index].connectedWifi,
                          color: Colors.white,
                          leadingIcon: Icons.wifi_tethering_rounded,
                          trailing: Icon(Icons.arrow_forward_ios_rounded),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        DevicePage(deviceList[index])));
                          });
                    })),
          ),
        )
      ],
    );
  }
}
