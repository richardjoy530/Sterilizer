import 'package:Sterilizer/model/data.dart';
import 'package:Sterilizer/ui/schedule_tile.dart';
import 'package:Sterilizer/utils/popups.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SchedulePage extends StatefulWidget {
  final Device device;

  SchedulePage(this.device);

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  Device get device => widget.device;

  @override
  void initState() {
    super.initState();
    device.setSchedulePageState(() {
      setState(() {
        device.schedules.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 30, bottom: 30),
              child: ListTile(
                title: Text(
                  "Schedule",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return index < device.schedules.length
                      ? GestureDetector(
                          onLongPress: () {
                            deleteSchedule(index);
                          },
                          child: ScheduleTile(device.schedules[index], device,
                              key: UniqueKey()))
                      : SizedBox(
                          height: 100,
                        );
                },
                itemCount: device.schedules.length + 1,
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            addNewSchedule();
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  addNewSchedule() {
    if (device.schedules.length < 5)
      setState(() {
        device.schedules.add(ScheduleData(
            startTime: TimeOfDay(hour: 6, minute: 15),
            endTime: TimeOfDay(hour: 7, minute: 15),
            state: false,
            days: [false, false, false, false, false, false, false],
            deviceId: device.id));
      });
    else
      Fluttertoast.showToast(
        msg: "Cannot add more than 5 schedules",
      );
  }

  deleteSchedule(int index) {
    deleteSchedulePopup().then((value) {
      if (value) {
        setState(() {
          device.schedules[index].deleteSchedule();
          device.schedules.removeAt(index);
          device.isSchedulesDirty = true;
          device.updateDevice();
        });
      }
    });
  }
}
