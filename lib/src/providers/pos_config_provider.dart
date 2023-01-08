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
  double totalCollection = 0;
  double offlineBalance  = 0;

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

  void getBalance() async {
    var db = await DbProvider().database;
    List<Map<String, dynamic>> dbTransactions =
    await db.query('pos_transactions');
    double offlineAmount = dbTransactions
        .map((e) => e['quantity'] * e['amount'])
        .fold(0.0, (total, subTotal) => (total + subTotal));
    totalCollection = offlineAmount;
    offlineBalance = posConfiguration?.offlineLimit != null ? posConfiguration!.offlineLimit-offlineAmount : 0.00;
    notifyListeners();
  }
}

final posConfigProvider = PosConfigProvider();
