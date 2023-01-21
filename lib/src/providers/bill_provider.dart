import 'package:flutter/material.dart';
import 'package:zanmutm_pos_client/src/api/api.dart';
import 'package:zanmutm_pos_client/src/mixin/message_notifier_mixin.dart';
import 'package:zanmutm_pos_client/src/models/bill.dart';
import 'package:zanmutm_pos_client/src/services/bill_service.dart';

class BillProvider extends ChangeNotifier with MessageNotifierMixin {

  List<Bill> _bills = List.empty(growable: true);
  bool _posIsConnected = true;
  bool _isLoading = false;
  String? _retryError;
  String? taxPayerUuid;

  void update(String? taxPayerUuid) {
    this.taxPayerUuid = taxPayerUuid;
  }

  List<Bill> get bills => _bills;
  set bills(List<Bill> val) {
    _bills = val;
    notifyListeners();
  }

  bool get posIsConnected =>_posIsConnected;
  set posIsConnected(bool val) {
    _posIsConnected = val;
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  String? get retryError=> _retryError;
  set retryError(String? val) {
    _retryError = val;
    notifyListeners();
  }

  loadPendingBills() async {
    try {
      _bills = await billService.getPendingBills(taxPayerUuid!);
      _isLoading = false;
      notifyListeners();
    } on NoInternetConnectionException {
      _posIsConnected = false;
      _isLoading = false;
      _retryError = 'No internet connection';
      notifyListeners();
      return false;
    } on DeadlineExceededException {
      _posIsConnected = false;
      _isLoading = false;
      _retryError = 'No internet connection';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _retryError = e.toString();
      notifyListeners();
    }
  }

  retry() async {
    _posIsConnected = true;
    _retryError = null;
    loadPendingBills();
  }
}
