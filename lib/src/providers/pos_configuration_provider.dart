import 'package:flutter/foundation.dart';
import 'package:zanmutm_pos_client/src/mixin/message_notifier_mixin.dart';
import 'package:zanmutm_pos_client/src/models/pos_configuration.dart';
import 'package:zanmutm_pos_client/src/services/pos_configuration_service.dart';
import 'package:zanmutm_pos_client/src/services/service.dart';

class PosConfigurationProvider extends ChangeNotifier
    with MessageNotifierMixin {
  bool _posConfigIsLoading = false;
  PosConfiguration? _posConfiguration;
 final posConfigService = getIt<PosConfigurationService>();
  bool get posConfigIsLoading => _posConfigIsLoading;

  set posConfigIsLoading(bool val) {
    _posConfigIsLoading = val;
    notifyListeners();
  }

  PosConfiguration? get posConfiguration => _posConfiguration;

  set posConfiguration(PosConfiguration? config) {
    _posConfiguration = config;
    notifyListeners();
  }

  loadPosConfig(String taxCollectorUuid) async {
    try {
      posConfiguration = await posConfigService.queryFromDb(taxCollectorUuid);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> fetchPosConfig(String taxCollectorUuid) async {
    posConfigIsLoading = true;
    try {
      var result = await posConfigService.fetchAndStore(taxCollectorUuid);
      if(result == null) {
        notifyError("No configuration found");
      }
      posConfiguration = result;
      posConfigIsLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
      posConfigIsLoading = false;
      notifyError(e.toString());
    }
  }
}
