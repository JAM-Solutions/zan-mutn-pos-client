import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/models/cart_item.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/providers/cart_provider.dart';
import 'package:zanmutm_pos_client/src/providers/revenue_collection_provider.dart';
import 'package:zanmutm_pos_client/src/providers/financial_year_provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_configuration_provider.dart';
import 'package:zanmutm_pos_client/src/screens/revenue_collection/collection_summary_table.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_form.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_text.dart';

class CollectCashDialog {
  final BuildContext context;
  final GlobalKey<FormBuilderState> _taxPayerForm =
      GlobalKey<FormBuilderState>();

  CollectCashDialog(this.context);

  collectCash(List<RevenueItem> items) async {
    var configProvider = context.read<PosConfigurationProvider>();
    var cartProvider_ = context.read<CartProvider>();
    var user = context.read<AppStateProvider>().user;
    var year = context.read<FinancialYearProvider>().financialYear;
    var taxCollectionProvider = context.read<RevenueCollectionProvider>();

    bool? confirmed = await openDialog(items);
    // bool? confirmed = await _openTaxPayerDialog();
    if (confirmed == true) {
      //get tax payer details from taxpayer form
      var taxPayerValues = _taxPayerForm.currentState!.value;
      bool success = await taxCollectionProvider.saveTransaction(
          items,
          user,
          year,
          taxPayerValues);
      if (success) {
        cartProvider_.clearItems();
      }
    }
  }

  Future<bool?> openDialog(List<RevenueItem> items) {
    return showDialog<bool?>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Text('Receipt'),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
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
        );
      },
    );
  }
}
