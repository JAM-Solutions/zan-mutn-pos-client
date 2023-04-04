import 'package:device_info_plus/device_info_plus.dart';
import 'package:zanmutm_pos_client/src/models/device_info.dart';

class DeviceInfoService {

  Future<AppDeviceInfo> getInfo(DeviceInfoPlugin infoPlugin) async {
      return  readAndroid(await infoPlugin.androidInfo);
  }

  AppDeviceInfo readAndroid(AndroidDeviceInfo build) {
    return AppDeviceInfo.fromJson({
      'id': build.display,
      'brand': build.brand,
      'manufacturer': build.manufacturer,
      'model': build.model,
    });
  }

}
