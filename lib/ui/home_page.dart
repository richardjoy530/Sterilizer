import 'dart:async';
import 'dart:io';

import 'package:Sterilizer/ui/device_page.dart';
import 'package:Sterilizer/ui/registration_process.dart';
import 'package:Sterilizer/utils/popups.dart';
import 'package:flutter/material.dart';
import 'package:wifi/wifi.dart';

import '../model/data.dart';
import 'dashboard_container.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void Function(void Function()) setBottomSheetState;

  @override
  void initState() {
    Device.setHomePageState(() {
      setState(() {});
    });
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
    return SafeArea(
      child: Scaffold(
        body: General(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            onAddDevicePressed();
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

  onAddDevicePressed() async {
    deviceIdTemp = -1;
    RegistrationProcess.currentStatus = 0;
    RegistrationProcess.currentStatusString = RegistrationProcess.PREPARING;
    var choice = await choseAddOptionPopUp();
    if (choice == AddDeviceChoice.ExistingDevice)
      await addExistingDevicePopUp();
    else if (choice == AddDeviceChoice.NewDevice) await addDevicePopup();
    if (deviceIdTemp != -1 && deviceNameTemp != "") await showBottomSheet();
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
        builder: (context) {
          return RegistrationProcessWidgets();
        });
  }
}
