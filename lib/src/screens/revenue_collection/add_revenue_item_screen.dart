import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:zanmutm_pos_client/src/models/cart_item.dart';
import 'package:zanmutm_pos_client/src/models/revenue_source.dart';
import 'package:zanmutm_pos_client/src/routes/app_routes.dart';
import 'package:zanmutm_pos_client/src/utils/helpers.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_form.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_hidden.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_integer.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_number.dart';

class AddRevenueItemScreen extends StatefulWidget {
  final RevenueSource source;

  const AddRevenueItemScreen({Key? key, required this.source})
      : super(key: key);

  @override
  State<AddRevenueItemScreen> createState() => _AddRevenueItemScreenState();
}

class _AddRevenueItemScreenState extends State<AddRevenueItemScreen> {
  final _addItemForm = GlobalKey<FormBuilderState>();
  double subTotal = 0;

  @override
  void initState() {
    super.initState();
    subTotal = widget.source.unitCost ?? 0.00 * 1;
  }

  calcSubTotal() {
    _addItemForm.currentState?.save();
    var formVal = _addItemForm.currentState?.value;
    setState(() => subTotal = formVal != null
        ? ((formVal['amount'] ?? 0) * (formVal['quantity'] ?? 0))
        : 0.0);
  }

  addItem() {
    if (_addItemForm.currentState?.saveAndValidate() == true) {
      Map<String, dynamic> formValues = _addItemForm.currentState!.value;
      RevenueItem item = RevenueItem.fromJson(formValues);
      appRoute.closeDialogPage(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBaseScreen(
      appBar: AppBar(
        title: const Text("Collect Revenue"),
      ),
      child: SingleChildScrollView(
        reverse: true,
        child: Column(
          children: [
            ListTile(
              dense: true,
              title: Text(widget.source.name),
              contentPadding: const EdgeInsets.all(0.0),
              subtitle: Text(widget.source.gfsCode),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(widget.source.name.substring(0, 1)),
              ),
            ),
            AppForm(
              initialValue: {
                'amount': widget.source.unitCost ?? 0.00,
                'quantity': 1
              },
              formKey: _addItemForm,
              controls: [
                AppInputHidden(
                  fieldName: 'revenueSource',
                  value: widget.source.toJson(),
                ),
                AppInputNumber(
                  name: 'amount',
                  label: "Amount",
                  enabled: !(widget.source.unitCost != null &&
                      widget.source.unitCost! > 0),
                  validators: [
                    FormBuilderValidators.required(
                        errorText: "Amount is required"),
                    FormBuilderValidators.min(widget.source.unitCost ?? 500,
                        errorText:
                            'Minimum is ${widget.source.unitCost ?? 500}')
                  ],
                  onChanged: (val) => calcSubTotal(),
                ),
                AppInputInteger(
                  name: 'quantity',
                  initialValue: 1,
                  label: "Quantity",
                  showSteps: true,
                  suffix: widget.source.unitName != null
                      ? Text(widget.source.unitName!)
                      : null,
                  validators: [
                    FormBuilderValidators.required(
                        errorText: "Quantity is required"),
                    FormBuilderValidators.min(1, errorText: 'Minimum 1')
                  ],
                  onChanged: (val) => calcSubTotal(),
                ),
                const Divider(color: Colors.black,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Sub Total: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(currency.format(subTotal),
                      style: const TextStyle(fontWeight: FontWeight.bold),)
                  ],
                ),
                const Divider(color: Colors.black,),
                AppInputHidden(
                    fieldName: 'revenueSourceId', value: widget.source.id),
                AppButton(label: 'Collect Cash', onPress: () => addItem())
              ],
            ),
          ],
        ),
      ),
    );
  }
}
