import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/models/cart_item.dart';
import 'package:zanmutm_pos_client/src/models/financial_year.dart';
import 'package:zanmutm_pos_client/src/models/pos_configuration.dart';
import 'package:zanmutm_pos_client/src/models/pos_transaction.dart';
import 'package:zanmutm_pos_client/src/models/user.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/providers/cart_provider.dart';
import 'package:zanmutm_pos_client/src/services/financial_year_service.dart';
import 'package:zanmutm_pos_client/src/services/pos_transaction_service.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_fetcher.dart';
import 'package:zanmutm_pos_client/src/widgets/app_form.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_dropdown.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_integer.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_number.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_text.dart';
import 'package:zanmutm_pos_client/src/widgets/app_messages.dart';

enum CartAction { cancel, collectCash, addToCart }

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;
  final _cartItemForm = GlobalKey<FormBuilderState>();
  final _taxPayerForm = GlobalKey<FormBuilderState>();
  late PosConfiguration? _posConfig;
  late FinancialYear? _year;
  late User? _user;
  late CartProvider _cartProvider;

  @override
  void initState() {
    _cartProvider = Provider.of(context, listen: false);
    var appProvider = Provider.of<AppStateProvider>(context, listen: false);
    _posConfig = appProvider.posConfiguration;
    _user = appProvider.user;
    _loadYear();
    super.initState();
  }

  _loadYear() async {
    _year = await financialYearService.fetchAndStore();
  }

  _addToCart() {
    Map<String, dynamic> formValues = _cartItemForm.currentState!.value;
    CartItem item = CartItem.fromJson(formValues);
    _cartProvider.addItem(item);
  }

  _collectCash() async {
    bool? confirmed = await _openTaxPayerDialog();
    if (confirmed == true) {
      var taxPayerValues = _taxPayerForm.currentState!.value;
      List<CartItem> items = _cartProvider.cartItems;
      DateTime t = DateTime.now();
      String transactionId = t.toIso8601String();
      String? printError = await _printReceipt();

      List<PosTransaction> posTxns = items
          .map((item) => PosTransaction.fromCashCollection(
              transactionId,
              transactionId,
              t,
              _posConfig!.posDeviceId,
              item,
              _user!,
              taxPayerValues,
              _year!.id,
              printError == null,
              printError))
          .toList();
      try {
        int result = await posTransactionService.saveAll(posTxns);
        if (result > 0) {
          _cartProvider.clearItems();
          _onSuccess('Successfully');
        } else {
          _onError('Something went wrong');
        }
      }catch(e) {
        _onError(e.toString());
      }
    }
  }

  _onSuccess(String message) {
    AppMessages.showSuccess(context, message);
  }

  _onError(String error) {
    AppMessages.showError(context, error);
    debugPrint(error);
  }

  //TODO
  Future<String?> _printReceipt() async {
    return 'No implementaion';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, provider, child) {
        var items = provider.cartItems;
        return AppBaseScreen(
            isLoading: _isLoading,
            appBar: AppBar(
              title: const Text("Cart"),
            ),
            floatingAction: FloatingActionButton(
              onPressed: () => _addUpdateItem(null),
              child: const Icon(Icons.add),
            ),
            child: ListView.separated(
                itemBuilder: (BuildContext context, idx) {
                  var item = items[idx];
                  return ListTile(
                    title: Text(item.revenueSource.name),
                    subtitle: Text('${item.amount} x ${item.quantity}'),
                    trailing: Text((item.quantity * item.amount).toString()),
                    onTap: () => _addUpdateItem(item),
                  );
                },
                separatorBuilder: (BuildContext context, idx) =>
                    const Divider(),
                itemCount: provider.cartItems.length));
      },
    );
  }

  _addUpdateItem(CartItem? cartItem) async {
    Map<String, dynamic> data = cartItem != null ? cartItem.toJson() : {};
    var result = await showDialog<CartAction?>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cart Item'),
          content: SingleChildScrollView(
            child: AppForm(
              initialValue: data,
              formKey: _cartItemForm,
              controls: [
                AppFetcher(
                    table: 'revenue_sources',
                    builder: (items, isLoading) {
                      return AppInputDropDown(
                        label: "Revenue Source",
                        displayValue: 'name',
                        items: items,
                        name: 'revenueSource',
                        validators: [
                          FormBuilderValidators.required(
                              errorText: "Source is required"),
                        ],
                      );
                    }),
                const AppInputInteger(name: 'quantity', label: "Quantity"),
                const AppInputNumber(name: 'amount', label: "Amount"),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  child: AppButton(
                      label: 'Add to Cart',
                      onPress: () {
                        if (_cartItemForm.currentState?.saveAndValidate() ==
                            true) {
                          Navigator.of(context).pop(CartAction.addToCart);
                        }
                      }),
                ),
                const SizedBox(
                  width: 4,
                ),
                Expanded(
                    child: AppButton(
                        label: 'Collect Cash',
                        onPress: () {
                          if (_cartItemForm.currentState?.saveAndValidate() ==
                              true) {
                            Navigator.of(context).pop(CartAction.collectCash);
                          }
                        }))
              ],
            )
          ],
        );
      },
    );
    if (result == CartAction.addToCart) {
      _addToCart();
    } else if (result == CartAction.collectCash) {
      _addToCart();
      _collectCash();
    }
  }

  Future<bool?> _openTaxPayerDialog() async {
    return showDialog<bool?>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cart Item'),
          content: SingleChildScrollView(
            child: AppForm(
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
