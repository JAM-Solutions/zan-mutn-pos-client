import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';
import 'package:zanmutm_pos_client/src/api/api.dart';
import 'package:zanmutm_pos_client/src/mixin/message_notifier_mixin.dart';
import 'package:zanmutm_pos_client/src/models/cart_item.dart';
import 'package:zanmutm_pos_client/src/models/financial_year.dart';
import 'package:zanmutm_pos_client/src/models/pos_transaction.dart';
import 'package:zanmutm_pos_client/src/models/revenue_source.dart';
import 'package:zanmutm_pos_client/src/models/user.dart';
import 'package:zanmutm_pos_client/src/providers/pos_status_provider.dart';
import 'package:zanmutm_pos_client/src/providers/revenue_source_provider.dart';
import 'package:zanmutm_pos_client/src/services/pos_transaction_service.dart';
import 'package:zanmutm_pos_client/src/utils/helpers.dart';

class RevenueCollectionProvider extends ChangeNotifier with MessageNotifierMixin {
  List<RevenueSource> _filteredSources = List.empty(growable: true);
  List<RevenueSource> _allSources = List.empty(growable: true);
  final PosStatusProvider posStatusProvider;
  String? _searchVal;

  RevenueCollectionProvider(this.posStatusProvider);

  List<RevenueSource> get revenueSources => _filteredSources;

  set revenueSources(List<RevenueSource> val) {
    _filteredSources = val;
    notifyListeners();
  }

  set searchVal(String? val) {
    _searchVal = val;
    filterSource();
  }

  void update(
      RevenueSourceProvider revenueSourceProvider) {
    _allSources = revenueSourceProvider.revenueSource;
    filterSource();
  }

  void filterSource() {
    if (_searchVal != null && _searchVal!.isNotEmpty) {
      revenueSources = _allSources
          .where((element) =>
              element.name.toLowerCase().contains(_searchVal!.toLowerCase()))
          .toList();
    } else {
      revenueSources = _allSources;
    }
  }

  Future<bool> saveTransaction(List<RevenueItem> items, int? posDeviceId, User? user,
      FinancialYear? year, Map<String, dynamic> taxPayerValues) async {
    //Use current time stamp as transaction id
    DateTime t = DateTime.now();
    String transactionId = t.toIso8601String();
    // Try printing receipt if fail it return print error
    String? printError = await _printReceipt(items);
    //For each cart items map then to PosTransaction object
    List<PosTransaction> posTxns = items
        .map((item) => PosTransaction.fromCashCollection(
            transactionId,
            transactionId,
            t,
            posDeviceId!,
            item,
            user!,
            taxPayerValues,
            year!.id,
            printError == null,
            printError))
        .toList();
    try {
      // Save all pos transactions
      int result = await posTransactionService.saveAll(posTxns);
      // If saved successfully clear cart items and show message
      // If not show error message
      if (result > 0) {
        notifyInfo("Successfully");
        _backGroundSyncTransaction();
        return true;
      } else {
        notifyError("Whoops Something went wrong");
        return false;
      }
    } catch (e) {
      notifyError(e.toString());
      return true;
    }
  }

  Future<String?> _printReceipt(List<RevenueItem> items) async {
    bool? connected = await SunmiPrinter.bindingPrinter();
    if (connected == true) {
      await SunmiPrinter.startTransactionPrint(true);
      try {
        Uint8List bytes = (await rootBundle.load('assets/images/logo.jpeg'))
            .buffer
            .asUint8List();
        await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
        await SunmiPrinter.printImage(bytes);
      } catch (e) {
        debugPrint(e.toString());
      }
      await SunmiPrinter.lineWrap(1); // Jump 2 lines
      // Center align
      for (var item in items) {
        await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
        await SunmiPrinter.printText(
            '${item.revenueSource.name}   ${item.quantity} x ${currency.format(item.amount)}',
            style: SunmiStyle(align: SunmiPrintAlign.RIGHT));
      }
      await SunmiPrinter.printText('--------------------------------');
      await SunmiPrinter.printText(
          'Total ${currency.format(items.map((e) => e.quantity * e.amount).fold(0.0, (acc, next) => acc + next))}',
          style: SunmiStyle(bold: true, align: SunmiPrintAlign.RIGHT));
      await SunmiPrinter.lineWrap(2); // Jump 2 lines
      //  await SunmiPrinter.cut();
      await SunmiPrinter.submitTransactionPrint(); // SUBMIT and cut paper
      await SunmiPrinter.exitTransactionPrint(true);
      return null;
    }
    debugPrint("not connected");
    return 'Print not connected';
  }

  _backGroundSyncTransaction() async {
    try {
      await posTransactionService.sync();
    } on NoInternetConnectionException {
      posStatusProvider.setOfflineTime();
    } on DeadlineExceededException {
      posStatusProvider.setOfflineTime();
    } catch (e) {
      posStatusProvider.setOfflineTime();
      debugPrint(e.toString());
    }
    posStatusProvider.loadStatus();
  }
}
