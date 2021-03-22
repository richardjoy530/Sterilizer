import 'package:Sterilizer/model/data.dart';
import 'package:Sterilizer/ui/schedule_tile.dart';
import 'package:Sterilizer/utils/popups.dart';
import 'package:flutter/material.dart';

class Schedule extends StatefulWidget {
  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  @override
  Widget build(BuildContext context) {
    return Column(
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
              return GestureDetector(
                  onLongPress: () {
                    deleteSchedule(index);
                  },
                  child: ScheduleTile(deviceList[0].schedules[index],
                      key: UniqueKey()));
            },
            itemCount:
                deviceList.isNotEmpty ? deviceList[0].schedules.length : 0,
          ),
        )
      ],
    );
  }

  void deleteSchedule(int index) {
    deleteSchedulePopup().then((value) {
      if (value) {
        setState(() {
          deviceList[0].schedules.removeAt(index);
          deviceList[0].updateSchedules();
        });
      }
    });
  }
}
