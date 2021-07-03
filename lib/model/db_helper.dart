import 'dart:io';

import 'package:Sterilizer/model/data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DataBaseHelper {
  static Database _db;

  static initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'ibis.db';
    _db = await openDatabase(path, version: 1, onCreate: _createDb);
  }

  static _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE Devices (id INTEGER PRIMARY KEY AUTOINCREMENT, deviceId TEXT, deviceName TEXT, settings TEXT)');
    await db.execute(
        'CREATE TABLE Schedules (id INTEGER PRIMARY KEY AUTOINCREMENT, scheduleId INTEGER , deviceId TEXT, schedule TEXT, settings TEXT)');
  }

  //----------------------------------------------------------------------------
  static addDevice(Device device) async => await _db
      .insert("Devices", {"deviceId": device.id, "deviceName": device.name});

  static Future<List<Device>> getAllDevices() async {
    List<Device> devices = [];
    var value = await _db.query("Devices");
    for (var map in value) {
      var schedules = await getSchedulesForDevice(map["deviceId"]);
      devices.add(Device.fromDB(
          id: map['deviceId'], name: map["deviceName"], schedules: schedules));
    }
    return devices;
  }

  static removeDevice(Device device) async =>
      await _db.delete("Devices", where: "deviceId = \"${device.id}\"");

  static updateDevice(Device device) async =>
      await _db.update("Devices", {"deviceName": device.name},
          where: "deviceId = \"${device.id}\"");

  //----------------------------------------------------------------------------
  static addSchedule(ScheduleData scheduleData, String deviceId) async =>
      await _db.insert("Schedules", {
        "deviceId": deviceId,
        "schedule": scheduleData.stringify(),
        "scheduleId": scheduleData.scheduleId
      });

  static removeSchedule(int scheduleId) async =>
      await _db.delete("Schedules", where: "scheduleId = $scheduleId");

  static updateSchedule(ScheduleData scheduleData) async =>
      await _db.update("Schedules", {"schedule": scheduleData.stringify()},
          where: "scheduleId = ${scheduleData.scheduleId}");

  static Future<List<ScheduleData>> getSchedulesForDevice(String deviceId) async {
    List<ScheduleData> schedules = [];
    var value = await _db.query("Schedules", where: "deviceId = \"$deviceId\"");
    for (var map in value)
      schedules
          .add(ScheduleData.fromString(map["schedule"], map["scheduleId"]));
    return schedules;
  }
}
