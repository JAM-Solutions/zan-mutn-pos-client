import 'package:device_info_plus/device_info_plus.dart';
import 'package:zanmutm_pos_client/src/models/device_info.dart';

class DeviceInfoService {
  static final DeviceInfoService _instance = DeviceInfoService._();
  factory DeviceInfoService() => _instance;
  DeviceInfoService._();

  Future<AppDeviceInfo> getInfo(DeviceInfoPlugin infoPlugin) async {
      return  readAndroid(await infoPlugin.androidInfo);
  }
  
  AppDeviceInfo readAndroid(AndroidDeviceInfo build) {
    return AppDeviceInfo.fromJson({
      'id': build.id,
      'brand': build.brand,
      'manufacturer': build.manufacturer,
      'model': build.model,
    });
  }
  
}