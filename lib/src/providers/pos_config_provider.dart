import 'package:flutter/foundation.dart';
import 'package:zanmutm_pos_client/src/db/db.dart';
import 'package:zanmutm_pos_client/src/models/device_info.dart';
import 'package:zanmutm_pos_client/src/models/financial_year.dart';
import 'package:zanmutm_pos_client/src/models/pos_configuration.dart';
import 'package:zanmutm_pos_client/src/models/revenue_source.dart';

class PosConfigProvider with ChangeNotifier {
  PosConfiguration? posConfiguration;
  FinancialYear? financialYear;
  AppDeviceInfo? deviceInfo;
  List<RevenueSource> revenueSource = List.empty(growable: false);

  void setDeviceInfo(AppDeviceInfo info) {
    deviceInfo = info;
    notifyListeners();
  }

  void setFinancialYear(FinancialYear? fy)  {
    financialYear = fy;
    notifyListeners();
  }

  void setRevenueSources(List<RevenueSource>? sources) {
    if (sources != null) {
      revenueSource = sources;
      notifyListeners();
    }
  }

  void setPosConfig(PosConfiguration? config) {
    posConfiguration = config;
    notifyListeners();
  }

}

final posConfigProvider = PosConfigProvider();
