import 'package:Sterilizer/model/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/data.dart';
import 'home_page.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    super.initState();
    contextStack.add(this.context);
    load();
  }

  @override
  void dispose() {
    contextStack.remove(this.context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Container(
            width: 50,
            child: Image.asset('images/icon.png'),
          ),
        ),
      ),
    );
  }

  load() async {
    DataBaseHelper.initializeDatabase();
    await Future.delayed(Duration(seconds: 2));
    try {
      deviceList = await DataBaseHelper
          .getAllDevices();
    }
    catch (e){
      Fluttertoast.showToast(msg: "DataBase Error: ${e.toString()}");
    }
    Fluttertoast.showToast(msg: "Couldn't check for permission");
    final bool result = await platform.invokeMethod('permission');
    if (result)
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    else
      Fluttertoast.showToast(msg: "Couldn't check for permission");
  }
}
