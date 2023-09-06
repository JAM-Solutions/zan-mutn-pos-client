import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mobiiot_printer/mobiiot_printer.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';
import 'package:zanmutm_pos_client/src/api/api.dart';
import 'package:zanmutm_pos_client/src/mixin/message_notifier_mixin.dart';
import 'package:zanmutm_pos_client/src/models/cart_item.dart';
import 'package:zanmutm_pos_client/src/models/device_info.dart';
import 'package:zanmutm_pos_client/src/models/financial_year.dart';
import 'package:zanmutm_pos_client/src/models/pos_registration.dart';
import 'package:zanmutm_pos_client/src/models/pos_transaction.dart';
import 'package:zanmutm_pos_client/src/models/receipt.dart';
import 'package:zanmutm_pos_client/src/models/revenue_source.dart';
import 'package:zanmutm_pos_client/src/models/user.dart';
import 'package:zanmutm_pos_client/src/providers/pos_status_provider.dart';
import 'package:zanmutm_pos_client/src/services/pos_transaction_service.dart';
import 'package:zanmutm_pos_client/src/services/service.dart';
import 'package:zanmutm_pos_client/src/utils/helpers.dart';

class RevenueCollectionProvider extends ChangeNotifier
    with MessageNotifierMixin {
  List<RevenueSource> _filteredSources = List.empty(growable: true);
  List<RevenueSource> _allSources = List.empty(growable: true);
  late PosStatusProvider posStatusProvider;
  late PosRegistration posRegistration;
  late AppDeviceInfo appDeviceInfo;
  final posTransactionService = getIt<PosTransactionService>();

  String? _searchVal;

  void update(revenueSourceProvider, posRegistration, posStatusProvider,
      appDeviceInfo) {
    this.posStatusProvider = posStatusProvider;
    this.posRegistration = posRegistration;
    this.appDeviceInfo = appDeviceInfo;
    _allSources = revenueSourceProvider.revenueSource;
    filterSource();
  }

  List<RevenueSource> get revenueSources => _filteredSources;

  set revenueSources(List<RevenueSource> val) {
    _filteredSources = val;
    notifyListeners();
  }

  set searchVal(String? val) {
    _searchVal = val;
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

  Future<bool> saveTransaction(List<RevenueItem> items, User? user,
      FinancialYear? year, Map<String, dynamic> taxPayerValues) async {
    //Use current time stamp as transaction id
    DateTime t = DateTime.now();
    String transactionId = t
        .toIso8601String()
        .replaceAll('-', '')
        .replaceAll(':', '')
        .replaceAll('.', '');
    String receiptNumber = transactionId;
    // Try printing receipt if fail it return print error
    String? printError = await _printReceipt(
        items,
        user!,
        receiptNumber,
        taxPayerValues['name'],
        dateFormat.format(t),
        user.taxCollectorUuid,
        appDeviceInfo.model);
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
            printError,
            posRegistration.id))
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

  Future<String?> _printReceipt(
      List<RevenueItem> items,
      User user,
      String receiptNumber,
      String? payerName,
      String date,
      uuid,
      String brand) async {
    Uint8List? logo;
    try {
      logo = (await rootBundle.load('assets/images/logo.jpeg'))
          .buffer
          .asUint8List();
    } catch (e) {
      debugPrint(e.toString());
    }
    String gov = "SERIKALI YA MAPINDUZI ZANZIBAR";
    String council =
        "(OR-TMSMIM) BARAZA LA MANISPAA \n ${user.adminHierarchyName}";
    String phone = 'Simu: +255716340430';
    String email = 'Email: mlandege.go.tz';
    String title = 'STAKABADHI YA MALIPO';
    String recNumber = 'Namba ya risit: $receiptNumber';
    String payer = 'Jina la Mlipaji: ${payerName ?? ''}';
    String total = currency.format(items
        .map((e) => e.quantity * e.amount)
        .fold(0.0, (acc, next) => acc + next));
    String receTotal = 'Malipo kwa Tarakimu: $total';
    String status = 'Hali ya Malipo: PAID';
    String paid = 'Jumla $total';
    String paidDate = 'Tarehe ya Kutoa risiti: $date';
    String printedBy =
        'Jina la mtoa risiti: ${user.firstName} ${user.lastName}';
    String qr =
        'Jina la Mlipaji: ${payerName}, \n Namba ya risit: $receiptNumber, \n Total $total, \n Jina la mtoa risiti: ${user.firstName} ${user.lastName}';
    Receipt receipt = Receipt(
        logo,
        gov,
        council,
        phone,
        email,
        title,
        recNumber,
        payer,
        total,
        receTotal,
        status,
        paid,
        paidDate,
        printedBy,
        qr);
    if ((brand.toUpperCase().contains('V2')
        || brand.toUpperCase().contains('V1')) &&
        !brand.contains('MP3') &&
        !brand.contains('MP4')) {
      return (await printSunMi(receipt, items));
    } else if (brand.contains('MP')) {
      return (await printMobiIot(receipt, items));
    } else {
      return "Printer not implemented";
    }
  }

  Future<String?> printSunMi(Receipt r, List<RevenueItem> items) async {
    try {
      bool? connected = await SunmiPrinter.bindingPrinter();
      if (connected == true) {
        await SunmiPrinter.startTransactionPrint(true);
        if (r.logo != null) {
          await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
          await SunmiPrinter.printImage(r.logo!);
        }
        await SunmiPrinter.lineWrap(2);
        await SunmiPrinter.printText(r.gov,
            style: SunmiStyle(bold: true, align: SunmiPrintAlign.CENTER));
        await SunmiPrinter.printText(r.council,
            style: SunmiStyle(bold: true, align: SunmiPrintAlign.CENTER));
        await SunmiPrinter.line();
        await SunmiPrinter.printText(r.phone,
            style: SunmiStyle(
                align: SunmiPrintAlign.CENTER, fontSize: SunmiFontSize.SM));
        await SunmiPrinter.printText(r.email,
            style: SunmiStyle(
                align: SunmiPrintAlign.CENTER, fontSize: SunmiFontSize.SM));
        await SunmiPrinter.line();
        await SunmiPrinter.printText(r.title, style: SunmiStyle(bold: true));
        await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
        await SunmiPrinter.printText(r.recNumber,
            style: SunmiStyle(fontSize: SunmiFontSize.MD));
        await SunmiPrinter.printText(r.payer,
            style: SunmiStyle(fontSize: SunmiFontSize.MD));
        await SunmiPrinter.printText(r.receTotal,
            style: SunmiStyle(fontSize: SunmiFontSize.MD));
        await SunmiPrinter.printText(r.status,
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
        await SunmiPrinter.printText(r.paid,
            style: SunmiStyle(bold: true, align: SunmiPrintAlign.RIGHT));
        await SunmiPrinter.lineWrap(2);
        await SunmiPrinter.printText(r.paidDate,
            style: SunmiStyle(fontSize: SunmiFontSize.MD));
        await SunmiPrinter.printText(r.printedBy,
            style: SunmiStyle(fontSize: SunmiFontSize.MD));
        await SunmiPrinter.lineWrap(1);
        await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
        await SunmiPrinter.printQRCode(r.qr, size: 3);
        await SunmiPrinter.lineWrap(4);
        await SunmiPrinter.submitTransactionPrint(); // SUBMIT and cut paper
        await SunmiPrinter.exitTransactionPrint(true);
        await SunmiPrinter.unbindingPrinter();
        return null;
      }
      debugPrint("not connected");
      return 'Print not connected';
    } catch(e) {
      notifyError(e.toString());
      return e.toString();
    }

  }

  Future<String?> printMobiIot(Receipt r, List<RevenueItem> items) async {
    try {
      String line = "-----------------------------------------";
      bool? connected = await MobiiotPrinter.bindingPrinter();
      if (connected == true) {
        if (r.logo != null) {
          await MobiiotPrinter.setAlignment(1);
          await MobiiotPrinter.printImage(r.logo!);
        }
        await MobiiotPrinter.lineWrap(2);
        await MobiiotPrinter.printText(r.gov, style: {"bold": true, "align": 1});
        await MobiiotPrinter.printText(r.council,
            style: {"bold": true, "align": 1});
        await MobiiotPrinter.printText(line, style: {"align": 1, "font": 1});
        await MobiiotPrinter.printText(r.phone, style: {"font": 1, "align": 1});
        await MobiiotPrinter.printText(r.email, style: {"font": 1, "align": 1});
        await MobiiotPrinter.printText(line, style: {"align": 1, "font": 1});
        await MobiiotPrinter.printText(r.title,
            style: {"bold": true, "align": 1});
        await MobiiotPrinter.printText(r.recNumber, style: {
          "font": 1,
          "bold": false,
        });
        await MobiiotPrinter.printText(r.payer, style: {
          "font": 1,
          "bold": false,
        });
        await MobiiotPrinter.printText(r.receTotal, style: {
          "font": 1,
          "bold": false,
        });
        await MobiiotPrinter.printText(r.status, style: {
          "font": 1,
          "bold": false,
        });
        await MobiiotPrinter.lineWrap(1); // Jump 2 lines
        // Center align
        for (var item in items) {
          await MobiiotPrinter.printText(
              '${item.revenueSource.name}   ${item.quantity} x ${currency.format(item.amount)}',
              style: {"font": 1, "align": 2});
        }
        await MobiiotPrinter.printText(line, style: {"align": 1, "font": 1});
        await MobiiotPrinter.printText(r.paid, style: {"align": 2, "font": 1});
        await MobiiotPrinter.lineWrap(2);
        await MobiiotPrinter.printText(r.paidDate, style: {"font": 1});
        await MobiiotPrinter.printText(r.printedBy, style: {"font": 1});
        await MobiiotPrinter.lineWrap(8);
        await MobiiotPrinter.unbindingPrinter();
        return null;
      }
      debugPrint("not connected");
      return 'Print not connected';
    } catch( e) {
      notifyError(e.toString());
      return e.toString();
    }

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
