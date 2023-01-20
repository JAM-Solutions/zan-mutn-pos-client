import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:zanmutm_pos_client/src/models/device_info.dart';

import '../services/device_info_service.dart';

class DeviceInfoProvider extends ChangeNotifier {
  AppDeviceInfo? _deviceInfo;

  AppDeviceInfo? get deviceInfo => _deviceInfo;

  set deviceInfo(AppDeviceInfo? val) {
    _deviceInfo = val;
    notifyListeners();
  }

  Future<void> loadDevice() async {
    final DeviceInfoPlugin infoPlugin = DeviceInfoPlugin();
    deviceInfo = await DeviceInfoService().getInfo(infoPlugin);
  }
}
