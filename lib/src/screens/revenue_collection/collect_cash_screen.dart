import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/models/cart_item.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/providers/financial_year_provider.dart';
import 'package:zanmutm_pos_client/src/providers/revenue_collection_provider.dart';
import 'package:zanmutm_pos_client/src/routes/app_routes.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_form.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_text.dart';

import 'collection_summary_table.dart';

class CollectCashScreen extends StatefulWidget {
  final List<RevenueItem> items;
  const CollectCashScreen({Key? key, required this.items}) : super(key: key);

  @override
  State<CollectCashScreen> createState() => _CollectCashScreenState();
}

class _CollectCashScreenState extends State<CollectCashScreen> {

  final GlobalKey<FormBuilderState> _taxPayerForm = GlobalKey<FormBuilderState>();

  saveTransactions() async {
    if (_taxPayerForm.currentState?.saveAndValidate() == true) {
      var user = context
          .read<AppStateProvider>()
          .user;
      var year = context
          .read<FinancialYearProvider>()
          .financialYear;
      var taxCollectionProvider = context.read<RevenueCollectionProvider>();
      var taxPayerValues = _taxPayerForm.currentState!.value;

      bool success = await taxCollectionProvider.saveTransaction(
          widget.items,
          user,
          year,
          taxPayerValues);
      if (success) {
        appRoute.closeDialogPage(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBaseScreen(
      appBar: AppBar(title: const Text("Print Receipt"),),
        child: SingleChildScrollView(
      reverse: true,
      child: Column(
        children: [
          CollectionSummaryTable(
            items: widget.items,
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
                  onPress: ()=>saveTransactions())
            ],
          ),
        ],
      ),
    ));
  }
}
