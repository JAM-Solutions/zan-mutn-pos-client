import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';
import 'package:zanmutm_pos_client/src/models/cart_item.dart';
import 'package:zanmutm_pos_client/src/models/pos_transaction.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/providers/cart_provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_config_provider.dart';
import 'package:zanmutm_pos_client/src/screens/cart/collection_summary_table.dart';
import 'package:zanmutm_pos_client/src/services/financial_year_service.dart';
import 'package:zanmutm_pos_client/src/services/pos_transaction_service.dart';
import 'package:zanmutm_pos_client/src/utils/helpers.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_form.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_text.dart';

class TaxPlayerDialog {
  final BuildContext context;
  final GlobalKey<FormBuilderState> _taxPayerForm =
      GlobalKey<FormBuilderState>();

  TaxPlayerDialog(this.context);

  collectCash(
      List<RevenueItem> items, Function onError, Function onSuccess) async {
    var configProvider = Provider.of<PosConfigProvider>(context, listen: false);
    var cartProvider_ = Provider.of<CartProvider>(context, listen: false);
    var user = Provider.of<AppStateProvider>(context, listen: false).user;
    var year = await financialYearService.fetchAndStore();

    bool? confirmed = await openDialog(items);
    // bool? confirmed = await _openTaxPayerDialog();
    if (confirmed == true) {
      //get tax payer details from taxpayer form
      var taxPayerValues = _taxPayerForm.currentState!.value;
      //Add last item to cart or single item when print single revenus source
      //Both multi item and single item added to card first before save and printed

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
              configProvider.posConfiguration!.posDeviceId,
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
          cartProvider_.clearItems();
          onSuccess('Successfully');
        } else {
          //TODO should it clear cart when faild to save all transactiosn
          onError('Something went wrong');
        }
      } catch (e) {
        // Catch other errors
        onError(e.toString());
      }
    }
  }

  Future<String?> _printReceipt(List<RevenueItem> items) async {
    bool? connected = await SunmiPrinter.bindingPrinter();
    if (connected == true) {
      await SunmiPrinter.startTransactionPrint(true);
      try {
        Uint8List bytes = (await rootBundle.load('assets/images/logo.jpeg')).buffer.asUint8List();
        await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
        await SunmiPrinter.printImage(bytes);
      } catch(e) {
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
      await SunmiPrinter.printText('---------------------------------');
      await SunmiPrinter.printText(
          'Total ${currency.format(items.map((e) => e.quantity * e.amount).fold(0.0, (acc, next) => acc + next))}',
          style: SunmiStyle(bold: true, align: SunmiPrintAlign.RIGHT));
      await SunmiPrinter.lineWrap(2); // Jump 2 lines
      await SunmiPrinter.submitTransactionPrint(); // SUBMIT and cut paper
      await SunmiPrinter.exitTransactionPrint(true);
      return null;
    }
    debugPrint("not connected");
    return 'Print not connected';
  }

  Future<bool?> openDialog(List<RevenueItem> items) {
    return showDialog<bool?>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Receipt'),
          content: SingleChildScrollView(
            reverse: true,
            child: Column(
              children: [
                CollectionSummaryTable(
                  items: items,
                ),
                AppForm(
                  formKey: _taxPayerForm,
                  controls: [
                    AppInputText(
                      fieldName: 'name',
                      label: 'Name/TIN',
                      validators: [
                        FormBuilderValidators.required(
                            errorText: 'Name is required'),
                      ],
                    ),
                    const AppInputText(fieldName: 'address', label: 'Address'),
                    AppButton(
                        label: 'Print',
                        onPress: () {
                          if (_taxPayerForm.currentState?.saveAndValidate() ==
                              true) {
                            Navigator.of(context).pop(true);
                          }
                        })
                  ],
                ),
              ],
            ),
          ),
          // actions: <Widget>[
          //   Row(
          //     children: [
          //       Expanded(
          //           child: AppButton(
          //               label: 'Print',
          //               onPress: () {
          //                 if (_taxPayerForm.currentState?.saveAndValidate() ==
          //                     true) {
          //                   Navigator.of(context).pop(true);
          //                 }
          //               }))
          //     ],
          //   )
          // ],
        );
      },
    );
  }
}
