import 'package:flutter/foundation.dart';
import 'package:zanmutm_pos_client/src/mixin/message_notifier_mixin.dart';
import 'package:zanmutm_pos_client/src/models/device_info.dart';
import 'package:zanmutm_pos_client/src/models/pos_configuration.dart';
import 'package:zanmutm_pos_client/src/services/pos_config_service.dart';

class PosConfigurationProvider extends ChangeNotifier with MessageNotifierMixin {
  bool _posConfigIsLoading = false;
  PosConfiguration? _posConfiguration;

  bool get posConfigIsLoading => _posConfigIsLoading;
  set posConfigIsLoading(bool val) {
    _posConfigIsLoading = val;
    notifyListeners();
  }

  PosConfiguration? get posConfiguration=> _posConfiguration;
  set posConfiguration(PosConfiguration? config) {
    _posConfiguration = config;
    notifyListeners();
  }

  loadPosConfig(AppDeviceInfo? device) async {
    if(device == null) {
      notifyError('No device id');
      return;
    }
    posConfigIsLoading = true;
    try {
      var result = await posConfigService.fetchAndStore(device.id);
      posConfiguration = result;
      posConfigIsLoading = false;
      notifyListeners();
    } catch(e) {
      debugPrint(e.toString());
      posConfigIsLoading = false;
      notifyError(e.toString());
    }
  }
}
