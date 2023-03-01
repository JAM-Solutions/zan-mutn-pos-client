import 'package:flutter/foundation.dart';
import 'package:zanmutm_pos_client/src/mixin/message_notifier_mixin.dart';
import 'package:zanmutm_pos_client/src/models/revenue_source.dart';
import 'package:zanmutm_pos_client/src/services/revenue_config_service.dart';
import 'package:zanmutm_pos_client/src/services/service.dart';

class RevenueSourceProvider extends ChangeNotifier with MessageNotifierMixin {
  bool _revSourcesIsLoading = false;
  List<RevenueSource> _revenueSource = List.empty(growable: false);
  final revenueSourceService = getIt<RevenueSourceService>();

  bool get revSourcesIsLoading => _revSourcesIsLoading;
  set revSourcesIsLoading(bool val) {
    _revSourcesIsLoading = val;
    notifyListeners();
  }

  List<RevenueSource> get revenueSource => _revenueSource;
  set revenueSource(List<RevenueSource> val) {
    _revenueSource = val;
    notifyListeners();
  }

  loadRevenueSource(String taxCollectorUuid) async {
    try {
      revenueSource = await  revenueSourceService.queryFromDb(taxCollectorUuid);
    } catch(e) {
      debugPrint(e.toString());
    }
  }


    fetchRevenueSource(String taxCollectorUuid) async {
    revSourcesIsLoading = true;
    try {
      revenueSource = await  revenueSourceService.fetchAndStore(taxCollectorUuid);
      revSourcesIsLoading = false;
    } catch(e) {
      debugPrint(e.toString());
      revSourcesIsLoading = false;
   //   notifyError(e.toString());
    }
  }

}
