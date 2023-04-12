import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';
import 'package:zanmutm_pos_client/src/api/api.dart';
import 'package:zanmutm_pos_client/src/mixin/message_notifier_mixin.dart';
import 'package:zanmutm_pos_client/src/models/cart_item.dart';
import 'package:zanmutm_pos_client/src/models/financial_year.dart';
import 'package:zanmutm_pos_client/src/models/pos_registration.dart';
import 'package:zanmutm_pos_client/src/models/pos_transaction.dart';
import 'package:zanmutm_pos_client/src/models/revenue_source.dart';
import 'package:zanmutm_pos_client/src/models/user.dart';
import 'package:zanmutm_pos_client/src/providers/pos_status_provider.dart';
import 'package:zanmutm_pos_client/src/providers/revenue_source_provider.dart';
import 'package:zanmutm_pos_client/src/services/pos_transaction_service.dart';
import 'package:zanmutm_pos_client/src/services/service.dart';
import 'package:zanmutm_pos_client/src/utils/helpers.dart';

class RevenueCollectionProvider extends ChangeNotifier
    with MessageNotifierMixin {
  List<RevenueSource> _filteredSources = List.empty(growable: true);
  List<RevenueSource> _allSources = List.empty(growable: true);
  final PosStatusProvider posStatusProvider;
  final PosRegistration posRegistration;
  final posTransactionService = getIt<PosTransactionService>();

  String? _searchVal;

  RevenueCollectionProvider(this.posStatusProvider, this.posRegistration);

  List<RevenueSource> get revenueSources => _filteredSources;

  set revenueSources(List<RevenueSource> val) {
    _filteredSources = val;
    notifyListeners();
  }

  set searchVal(String? val) {
    _searchVal = val;
    filterSource();
  }

  void update(RevenueSourceProvider revenueSourceProvider) {
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

  Future<bool> saveTransaction(
      List<RevenueItem> items,
      User? user,
      FinancialYear? year,
      Map<String, dynamic> taxPayerValues) async {
    //Use current time stamp as transaction id
    DateTime t = DateTime.now();
    String transactionId = t.toIso8601String().replaceAll('-', '').replaceAll(':', '').replaceAll('.', '');
    String receiptNumber = transactionId;
    // Try printing receipt if fail it return print error
    String? printError = await _printReceipt(items, user!, receiptNumber,
        taxPayerValues['name'], dateFormat.format(t), user.taxCollectorUuid);
    //For each cart items map then to PosTransaction object
    List<PosTransaction> posTxns = items
        .map((item) => PosTransaction.fromCashCollection(
            transactionId,
            receiptNumber,
            t,
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
        backGroundSyncTransaction(user!.taxCollectorUuid!);
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

  Future<String?> _printReceipt(List<RevenueItem> items, User user,
      String receiptNumber, String? payerName, String date, uuid) async {
    // final String api = '/councils';
    // AppStateProvider? adminHierarchyId;
    // var id = AppStateProvider().user!.adminHierarchyId;
    // var resp = await Api().dio.get('$api/$id');
    // List councils = jsonDecode(resp.data['data']);

    // Council? council;
    // print(councils[1]['email']);
    // print(council!.email == null ? 'm' : council.email.toString());
    bool? connected = await SunmiPrinter.bindingPrinter();
    if (connected == true) {
      String total = currency.format(items
          .map((e) => e.quantity * e.amount)
          .fold(0.0, (acc, next) => acc + next));
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

      await SunmiPrinter.lineWrap(2);
      await SunmiPrinter.printText("SERIKALI YA MAPINDUZI ZANZIBAR",
          style: SunmiStyle(bold: true, align: SunmiPrintAlign.CENTER));
      await SunmiPrinter.printText(
          "(OR-TMSMIM) BARAZA LA MANISPAA \n ${user.adminHierarchyName}",
          style: SunmiStyle(bold: true, align: SunmiPrintAlign.CENTER));
      await SunmiPrinter.line();
      await SunmiPrinter.printText('Simu: +255716340430',
          style: SunmiStyle(
              align: SunmiPrintAlign.CENTER, fontSize: SunmiFontSize.SM));
      await SunmiPrinter.printText('Email: mlandege.go.tz',
          style: SunmiStyle(
              align: SunmiPrintAlign.CENTER, fontSize: SunmiFontSize.SM));
      await SunmiPrinter.line();
      await SunmiPrinter.printText('STAKABADHI YA MALIPO',
          style: SunmiStyle(bold: true));
      await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
      await SunmiPrinter.printText('Namba ya risit: $receiptNumber',
          style: SunmiStyle(fontSize: SunmiFontSize.MD));
      await SunmiPrinter.printText('Jina la Mlipaji: ${payerName ?? ''}',
          style: SunmiStyle(fontSize: SunmiFontSize.MD));
      await SunmiPrinter.printText('Malipo kwa Tarakimu: $total',
          style: SunmiStyle(fontSize: SunmiFontSize.MD));
      await SunmiPrinter.printText('Hali ya Malipo: PAID',
          style: SunmiStyle(fontSize: SunmiFontSize.MD));
      await SunmiPrinter.lineWrap(1); // Jump 2 lines
      // Center align
      for (var item in items) {
        await SunmiPrinter.printText(
            '${item.revenueSource.name}   ${item.quantity} x ${currency.format(item.amount)}',
            style: SunmiStyle(
                align: SunmiPrintAlign.RIGHT, fontSize: SunmiFontSize.MD));
      }
      await SunmiPrinter.line();
      await SunmiPrinter.printText('Jumla $total',
          style: SunmiStyle(bold: true, align: SunmiPrintAlign.RIGHT));
      await SunmiPrinter.lineWrap(2);
      await SunmiPrinter.printText('Tarehe ya Kutoa risiti: $date',
          style: SunmiStyle(fontSize: SunmiFontSize.MD));
      await SunmiPrinter.printText(
          'Jina la mtoa risiti: ${user.firstName} ${user.lastName}',
          style: SunmiStyle(fontSize: SunmiFontSize.MD));
      await SunmiPrinter.lineWrap(1);
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      await SunmiPrinter.printQRCode(
          'Jina la Mlipaji: ${payerName}, \n Namba ya risit: $receiptNumber, \n Total $total, \n Jina la mtoa risiti: ${user.firstName} ${user.lastName}', size: 3
          );
      await SunmiPrinter.lineWrap(4);
      await SunmiPrinter.submitTransactionPrint(); // SUBMIT and cut paper
      await SunmiPrinter.exitTransactionPrint(true);
      return null;
    }
    debugPrint("not connected");
    return 'Print not connected';
  }

  backGroundSyncTransaction(String taxCollectorUuid) async {
    try {
      await posTransactionService.sync(taxCollectorUuid);
      posStatusProvider.resetOfflineTime();
    } on NoInternetConnectionException {
      posStatusProvider.setOfflineTime();
      posStatusProvider.loadTotalCollection();
    } on DeadlineExceededException {
      posStatusProvider.setOfflineTime();
      posStatusProvider.loadTotalCollection();
    } catch (e) {
      posStatusProvider.setOfflineTime();
      posStatusProvider.loadTotalCollection();
      debugPrint(e.toString());
    }
  }
}
