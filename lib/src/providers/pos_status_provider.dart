
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zanmutm_pos_client/src/db/db.dart';
import 'package:zanmutm_pos_client/src/services/pos_transaction_service.dart';
import 'package:zanmutm_pos_client/src/services/service.dart';
import 'package:zanmutm_pos_client/src/utils/app_const.dart';

class PosStatusProvider with ChangeNotifier {

  final posTransactionService = getIt<PosTransactionService>();

  DateTime? lastOffline;
  int offlineTime = 0;
  double totalCollection = 0;

  setOfflineTime() async {
    var now_ = DateTime.now();
    if(lastOffline == null) {
      lastOffline = now_;
      offlineTime = 0;
    } else {
      Duration diff = now_.difference(lastOffline!);
      offlineTime = offlineTime + diff.inSeconds;
      lastOffline = now_;
    }
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(AppConst.lastOffline, lastOffline!.toIso8601String());
    prefs.setInt(AppConst.offlineTime, offlineTime);
  }

  resetOfflineTime() async {
    lastOffline = null;
    offlineTime = 0;
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConst.lastOffline);
    await prefs.remove(AppConst.offlineTime);
    loadTotalCollection();
  }

  void loadStatus()  {
    loadTotalCollection();
    _loadOfflineTime();
  }

  void _loadOfflineTime()  async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    offlineTime =   prefs.getInt(AppConst.offlineTime) ?? 0;
    final String? lastOfLine_ = prefs.getString(AppConst.lastOffline);
    lastOffline = lastOfLine_ != null ? DateTime.parse(lastOfLine_) : null;
    notifyListeners();
  }

  void loadTotalCollection() async{
    var db = await DbProvider().database;
    List<Map<String, dynamic>> dbTransactions =
    await db.query('pos_transactions');
    double offlineAmount = dbTransactions
        .map((e) => e['quantity'] * e['amount'])
        .fold(0.0, (total, subTotal) => (total + subTotal));
    totalCollection = offlineAmount;
    notifyListeners();
  }

  syncTransactions() async {
    try {
     bool synced =  await posTransactionService.sync();
     if(synced) {
       resetOfflineTime();
     }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
