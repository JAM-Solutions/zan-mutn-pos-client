
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zanmutm_pos_client/src/db/db.dart';
import 'package:zanmutm_pos_client/src/services/pos_transaction_service.dart';
import 'package:zanmutm_pos_client/src/utils/app_const.dart';

class PosStatusProvider with ChangeNotifier {

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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(AppConst.lastOffline, lastOffline!.toIso8601String());
    prefs.setInt(AppConst.offlineTime, offlineTime);
    notifyListeners();
  }

  resetOfflineTime() async {
    lastOffline = null;
    offlineTime = 0;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(AppConst.lastOffline);
    prefs.remove(AppConst.offlineTime);
    loadStatus();
  }

  void loadStatus()  {
    _loadTotalCollection();
    _loadOfflineTime();
  }

  void _loadOfflineTime()  async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    offlineTime =  prefs.getInt(AppConst.offlineTime) ?? 0;
    final String? lastOfLine_ = prefs.getString(AppConst.lastOffline);
    lastOffline = lastOfLine_ != null ? DateTime.parse(lastOfLine_) : null;
    notifyListeners();
  }

  void _loadTotalCollection() async{
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

final posStatusProvider = PosStatusProvider();
