import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/models/cart_item.dart';
import 'package:zanmutm_pos_client/src/models/revenue_source.dart';
import 'package:zanmutm_pos_client/src/providers/cart_provider.dart';
import 'package:zanmutm_pos_client/src/screens/dashboard/collect_cash_dialog.dart';
import 'package:zanmutm_pos_client/src/screens/dashboard/dashboard_screen.dart';
import 'package:zanmutm_pos_client/src/utils/helpers.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_form.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_hidden.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_integer.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_number.dart';

class AddRevenueItemDialog {
  final BuildContext context;
  final _addItemForm = GlobalKey<FormBuilderState>();

  AddRevenueItemDialog(this.context);

  Future<bool?> addItem(RevenueSource source) async {
    var cartProvider_ = context.read<CartProvider>();
    var collectCashDialog = CollectCashDialog(context);

    var result = await openDialog(source);
    if (result == OnAddAction.cancel) return null;

    Map<String, dynamic> formValues = _addItemForm.currentState!.value;
    RevenueItem item = RevenueItem.fromJson(formValues);
    if (result == OnAddAction.addToCart) {
      cartProvider_.addItem(item);
      return true;
    } else if (result == OnAddAction.collectCash) {
      if (cartProvider_.cartItems.isNotEmpty) {
        cartProvider_.addItem(item);
        await collectCashDialog.collectCash(cartProvider_.cartItems);
      } else {
        await collectCashDialog.collectCash([item]);
      }
      return true;
    }
    return null;
  }

  Future<OnAddAction?> openDialog(RevenueSource source) {
    return showDialog<OnAddAction?>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        double subTotal = 0;
        return AlertDialog(
          title: ListTile(
            dense: true,
            title: Text(source.name),
            contentPadding: const EdgeInsets.all(0.0),
            subtitle: Text(source.gfsCode),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(source.name.substring(0, 1)),
            ),
          ),
          content: StatefulBuilder(
              builder: (BuildContext _, StateSetter setDialogState) {
            calcSubTotal() {
              _addItemForm.currentState?.save();
              var formVal = _addItemForm.currentState?.value;
              setDialogState(() => subTotal = formVal != null
                  ? ((formVal['amount'] ?? 0) * (formVal['quantity'] ?? 0))
                  : 0.0);
            }

            return SingleChildScrollView(
              child: AppForm(
                initialValue: {'amount': source.unitCost ?? 0.00},
                formKey: _addItemForm,
                controls: [
                  AppInputHidden(
                    fieldName: 'revenueSource',
                    value: source.toJson(),
                  ),
                  AppInputNumber(
                    name: 'amount',
                    label: "Amount",
                    enabled: !(source.unitCost != null && source.unitCost! > 0),
                    validators: [
                      FormBuilderValidators.required(
                          errorText: "Amount is required"),
                      FormBuilderValidators.min(source.unitCost ?? 500,
                          errorText: 'Minimum is ${source.unitCost ?? 500}')
                    ],
                    onChanged: (val) => calcSubTotal(),
                  ),
                  AppInputInteger(
                    name: 'quantity',
                    label: "Quantity",
                    suffix:
                        source.unitName != null ? Text(source.unitName!) : null,
                    validators: [
                      FormBuilderValidators.required(
                          errorText: "Quantity is required"),
                      FormBuilderValidators.min(1, errorText: 'Minimum 1')
                    ],
                    onChanged: (val) => calcSubTotal(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        "Sub Total: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(currency.format(subTotal))
                    ],
                  ),
                  AppInputHidden(
                      fieldName: 'revenueSourceId', value: source.id),
                ],
              ),
            );
          }),
          actions: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppButton(
                    label: 'Add to Cart',
                    onPress: () {
                      if (_addItemForm.currentState?.saveAndValidate() ==
                          true) {
                        Navigator.of(context).pop(OnAddAction.addToCart);
                      }
                    }),
                Consumer<CartProvider>(
                  builder: (context, provider, child) {
                    if (provider.cartItems.isNotEmpty) {
                      return ElevatedButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Add & Checkout'),
                            const SizedBox(
                              width: 16,
                            ),
                            Badge(
                              badgeContent: Text(
                                  cartProvider.cartItems.length.toString()),
                              padding: const EdgeInsets.all(6),
                              position:
                                  BadgePosition.topEnd(top: -20, end: -16),
                              child: const Icon(Icons.shopping_cart),
                            ),
                          ],
                        ),
                        onPressed: () {
                          if (_addItemForm.currentState?.saveAndValidate() ==
                              true) {
                            Navigator.of(context).pop(OnAddAction.collectCash);
                          }
                        },
                      );
                    }
                    return AppButton(
                        label: 'Collect Cash',
                        onPress: () {
                          if (_addItemForm.currentState?.saveAndValidate() ==
                              true) {
                            Navigator.of(context).pop(OnAddAction.collectCash);
                          }
                        });
                  },
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
