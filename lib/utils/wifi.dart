import '../model/data.dart';

class Wifi {
  registerNewDevice() {
    final Map<String, String> cred = {
      'ssid': DEVICE_SSID,
      "password": DEVICE_PASSWORD
    };
    platform.invokeMethod("register", cred);
  }

  Future<String> getSSID() async {
    return platform.invokeMethod('ssid');
  }
}
