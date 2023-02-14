import 'package:flutter/material.dart';
import 'package:zanmutm_pos_client/src/api/api.dart';
import 'package:zanmutm_pos_client/src/mixin/message_notifier_mixin.dart';
import 'package:zanmutm_pos_client/src/models/pos_charge.dart';
import 'package:zanmutm_pos_client/src/models/pos_transaction.dart';
import 'package:zanmutm_pos_client/src/services/pos_charge_service.dart';
import 'package:zanmutm_pos_client/src/services/pos_transaction_service.dart';
import 'package:zanmutm_pos_client/src/services/service.dart';

class GenerateBillProvider extends ChangeNotifier with MessageNotifierMixin {
  bool _posConnected = true;
  bool _transactionSynced = false;
  bool _allTransactionsCompiled = false;
  bool _allBillsGenerated = false;
  String? _retryError;
  List<PosCharge> _taxCollectorCharges = List.empty();
  List<PosTransaction> _taxCollectorUnCompiled = List.empty(growable: true);
  String? taxCollectorUuid;
  final posTransactionService = getIt<PosTransactionService>();

  /// This provider depends on current logged in user
  /// This function is used to update tax collector uuid when user state changed*/
  void update(String? taxCollectorUuid) {
    this.taxCollectorUuid = taxCollectorUuid;
  }

  bool get posIsConnected => _posConnected;

  set posIsConnected(bool val) {
    _posConnected = val;
    notifyListeners();
  }

  bool get transactionSynced => _transactionSynced;

  set transactionSynced(bool val) {
    _transactionSynced = val;
    notifyListeners();
  }

  bool get allTransactionsCompiled => _allTransactionsCompiled;

  set allTransactionsCompiled(bool val) {
    _allTransactionsCompiled = val;
    notifyListeners();
  }

  bool get allBillsGenerated => _allBillsGenerated;

  set allBillGenerated(bool val) {
    _allBillsGenerated = val;
    notifyListeners();
  }

  String? get retryError => _retryError;

  set retryError(String? val) {
    _retryError = val;
    notifyListeners();
  }

  List<PosCharge> get taxCollectorCharges => _taxCollectorCharges;

  set taxCollectorCharges(List<PosCharge> val) {
    _taxCollectorCharges = val;
    notifyListeners();
  }

  List<PosTransaction> get taxCollectorUnCompiled => _taxCollectorUnCompiled;

  set taxCollectorUnCompiled(List<PosTransaction> val) {
    _taxCollectorUnCompiled = val;
    notifyListeners();
  }

  ///Initialize bill generated process by resetting all state to default and sysnc
  init() async {
    _posConnected = true;
    _transactionSynced = false;
    _allTransactionsCompiled = false;
    _allBillsGenerated = false;
    _retryError = null;
    _taxCollectorCharges = List.empty();
    _taxCollectorUnCompiled = List.empty(growable: true);
    notifyListeners();
    syncAndLoad();
  }

  syncAndLoad() async {
    await _syncTransaction();
    await _getUnCompiled();
  }

//Sync all transaction saved locally in pos device
  _syncTransaction() async {
    try {
      bool synced = await posTransactionService.sync();
      transactionSynced = synced;
    } on NoInternetConnectionException {
      posIsConnected = false;
      return false;
    } on DeadlineExceededException {
      posIsConnected = false;
    } catch (e) {
      retryError = e.toString();
      debugPrint(e.toString());
    }
  }

  // Get all Un compiled transaction to generate Charge Summary
  _getUnCompiled() async {
    if (_transactionSynced) {
      try {
        List<PosTransaction> transaction =
            await posTransactionService.getUnCompiled(taxCollectorUuid!);
        _taxCollectorUnCompiled = transaction;
        _allTransactionsCompiled = transaction.isEmpty;
        notifyListeners();
        if (transaction.isEmpty) {
          loadCharges();
        }
      } on NoInternetConnectionException {
        posIsConnected = false;
      } on DeadlineExceededException {
        posIsConnected = false;
      } catch (e) {
        retryError = e.toString();
        debugPrint(e.toString());
      }
    }
  }

  loadCharges() async {
    try {
      taxCollectorCharges =
          await getIt<PosChargeService>().getPendingCharges(taxCollectorUuid!);
      allBillGenerated = taxCollectorCharges.isEmpty;
    } on NoInternetConnectionException {
      posIsConnected = false;
      return false;
    } on DeadlineExceededException {
      posIsConnected = false;
      notifyError('hhh');
    } catch (e) {
      retryError = e.toString();
      debugPrint(e.toString());
    }
  }

  compileTransactions() async {
    if (_transactionSynced) {
      allTransactionsCompiled = false;
      try {
        int? status = await posTransactionService.compile(taxCollectorUuid!);
        if (status == 200) {
          allTransactionsCompiled = true;
          loadCharges();
        }
      } on NoInternetConnectionException {
        posIsConnected = false;
      } on DeadlineExceededException {
        posIsConnected = false;
      } catch (e) {
        retryError = e.toString();
        debugPrint(e.toString());
      }
    }
  }

  generateBill() async {
    try {
      await getIt<PosChargeService>().createBill(taxCollectorUuid!);
      loadCharges();
      notifyInfo("Bill generated successfully");
    } on NoInternetConnectionException {
      posIsConnected = false;
    } on DeadlineExceededException {
      posIsConnected = false;
    } catch (e) {
      retryError = e.toString();
      debugPrint(e.toString());
    }
  }

  retry() async {
    _posConnected = true;
    _retryError = null;
    notifyListeners();
    if (!_transactionSynced) {
      syncAndLoad();
      return;
    } else if (!_allTransactionsCompiled) {
      compileTransactions();
      return;
    } else if (!_allBillsGenerated) {
      generateBill();
      return;
    }
  }
}
