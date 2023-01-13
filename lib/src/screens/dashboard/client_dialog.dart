import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/models/cart_item.dart';
import 'package:zanmutm_pos_client/src/models/pos_transaction.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/providers/cart_provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_config_provider.dart';
import 'package:zanmutm_pos_client/src/services/financial_year_service.dart';
import 'package:zanmutm_pos_client/src/services/pos_transaction_service.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_form.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_text.dart';

class TaxPlayerDialog {
  final BuildContext context;
  final GlobalKey<FormBuilderState> _taxPayerForm =
      GlobalKey<FormBuilderState>();

  TaxPlayerDialog(this.context);

  collectCash(Function onError, Function onSuccess) async {
    var configProvider = Provider.of<PosConfigProvider>(context, listen: false);
    var cartProvider = Provider.of<CartProvider>(context, listen: false);
    var user = Provider.of<AppStateProvider>(context, listen: false).user;
    var year = await financialYearService.fetchAndStore();

    bool? confirmed = await openDialog();
    // bool? confirmed = await _openTaxPayerDialog();
    if (confirmed == true) {
      //get tax payer details from taxpayer form
      var taxPayerValues = _taxPayerForm.currentState!.value;
      //Add last item to cart or single item when print single revenus source
      //Both multi item and single item added to card first before save and printed

      List<CartItem> items = cartProvider.cartItems;

      //Use current time stamp as transaction id
      DateTime t = DateTime.now();
      String transactionId = t.toIso8601String();

      // Try printing receipt if fail it return print error
      String? printError = await _printReceipt();

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
          cartProvider.clearItems();
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

  Future<String?> _printReceipt() async {
    return 'No implementation';
  }

  Future<bool?> openDialog() {
    return showDialog<bool?>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Receipt'),
          content: SingleChildScrollView(
            child: AppForm(
              formKey: _taxPayerForm,
              controls: [
                Text('Summary here'),
                AppInputText(
                  fieldName: 'name',
                  label: 'Name/TIN',
                  validators: [
                    FormBuilderValidators.required(
                        errorText: 'Name is required'),
                  ],
                ),
                const AppInputText(fieldName: 'address', label: 'Address'),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                    child: AppButton(
                        label: 'Print',
                        onPress: () {
                          if (_taxPayerForm.currentState?.saveAndValidate() ==
                              true) {
                            Navigator.of(context).pop(true);
                          }
                        }))
              ],
            )
          ],
        );
      },
    );
  }
}
