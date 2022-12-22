import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/models/financial_year.dart';
import 'package:zanmutm_pos_client/src/models/pos_configuration.dart';
import 'package:zanmutm_pos_client/src/models/pos_transaction.dart';
import 'package:zanmutm_pos_client/src/models/revenue_source.dart';
import 'package:zanmutm_pos_client/src/models/user.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/services/financial_year_service.dart';
import 'package:zanmutm_pos_client/src/services/pos_transaction_service.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_form.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_integer.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_number.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_text.dart';
import 'package:zanmutm_pos_client/src/widgets/app_messages.dart';

class CashCollectionScreen extends StatefulWidget {
  final RevenueSource revenueSource;

  const CashCollectionScreen({Key? key, required this.revenueSource})
      : super(key: key);

  @override
  State<CashCollectionScreen> createState() => _CashCollectionScreenState();
}

class _CashCollectionScreenState extends State<CashCollectionScreen> {
  int _stepIndex = 0;
  bool _billFormHasError = false;
  bool _taxPayerFormHasError = false;
  late PosConfiguration? _posConfig;
  late FinancialYear? _year;
  late User? _user;

  final _billForm = GlobalKey<FormBuilderState>();
  final _taxPayerForm = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    var appProvider = Provider.of<AppStateProvider>(context, listen: false);
    _posConfig = appProvider.posConfiguration;
    _user = appProvider.user;
    _loadYear();
    super.initState();
  }

  _loadYear() async {
    _year = await financialYearService.fetchAndStore();
  }

  _confirmCollection() async {
    var cashBill = {
      ..._billForm.currentState!.value,
      ..._taxPayerForm.currentState!.value
    };
    PosTransaction txn = PosTransaction.fromCashCollection(
        _posConfig!, widget.revenueSource, _user!, cashBill, _year!.id);
    var confirmed = await _openBillDialog(txn);
    if (confirmed == true) {

      try{
        bool printed = await _printReceipt();
        txn.isPrinted = printed;
        int? result = await posTransactionService.save(txn);
        if (result == 200 || result == 201) {
          _onSuccess();
        } else {
          _onError(result.toString());
        }
      }catch(e) {
        _onError(e.toString());
      }

    }
  }

  _onSuccess() {
    AppMessages.showSuccess(context, 'Saved');
    context.pop();
  }

  _onError(String error) {
    AppMessages.showError(context, error);
    debugPrint(error);

  }

  Future<bool> _printReceipt() async {
    return false;
  }

  Future<bool?> _openBillDialog(PosTransaction txn) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Year: ${_year!.name}'),
                Text('Item: ${widget.revenueSource.name}'),
                Text('Tax Payer: ${txn.cashPayerName}'),
                Text('Address : ${txn.cashPayerAddress ?? ''}'),
                Text('Amount: ${txn.amount}'),
                Text('Quantity: ${txn.quantity}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Confirm & Print'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  _onStepContinue() {
    switch (_stepIndex) {
      case 0:
        if (_billForm.currentState!.saveAndValidate()) {
          setState(() {
            _stepIndex += 1;
            _billFormHasError = false;
          });
        } else {
          setState(() {
            _billFormHasError = true;
          });
        }
        break;
      case 1:
        if (_taxPayerForm.currentState!.saveAndValidate()) {
          setState(() {
            _taxPayerFormHasError = false;
          });
          _confirmCollection();
        } else {
          setState(() {
            _taxPayerFormHasError = true;
          });
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBaseScreen(
        padding: const EdgeInsets.all(0),
        appBar: AppBar(
          elevation: 0,
          title: Text(
              "Collect ${widget.revenueSource.name} - ${widget.revenueSource.gfsCode}"),
        ),
        child: ListView(children: [
          Stepper(
            physics: const ClampingScrollPhysics(),
            margin: const EdgeInsets.fromLTRB(52, 4, 16, 2),
            currentStep: _stepIndex,
            steps: [
              Step(
                title: const Text('Bill Amount'),
                content: AppForm(
                  formKey: _billForm,
                  controls: [
                    AppInputNumber(
                      name: 'amount',
                      label: 'Amount',
                      validators: [
                        FormBuilderValidators.required(
                            errorText: 'Amount is required'),
                        FormBuilderValidators.min(50,
                            errorText: 'Amount min value is 50')
                      ],
                    ),
                    AppInputInteger(
                      name: 'quantity',
                      label: 'Quantity',
                      validators: [
                        FormBuilderValidators.required(
                            errorText: 'Quantity is required'),
                        FormBuilderValidators.min(1,
                            errorText: 'Quantity minvalue is 1')
                      ],
                    ),
                  ],
                ),
              ),
              Step(
                title: const Text('Tax Payer'),
                content: AppForm(
                  formKey: _taxPayerForm,
                  controls: [
                    AppInputText(
                      fieldName: 'name',
                      label: 'Name/TIN',
                      validators: [
                        FormBuilderValidators.required(
                            errorText: 'Tax payer is required'),
                      ],
                    ),
                    AppInputText(fieldName: 'address', label: 'Address'),
                  ],
                ),
              ),
            ],
            controlsBuilder: (context, details) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: Text(_stepIndex == 1 ? 'SUBMIT' : 'NEXT'),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  if (_stepIndex != 0)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('BACK'),
                    ),
                ],
              );
            },
            onStepCancel: () {
              if (_stepIndex > 0) {
                setState(() {
                  _stepIndex -= 1;
                });
              }
            },
            onStepContinue: () => _onStepContinue(),
          ),
        ]));
  }
}
