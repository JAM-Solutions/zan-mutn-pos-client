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
import 'package:zanmutm_pos_client/src/utils/helpers.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_tab_screen.dart';
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
      } catch (e) {
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

  _getTableHeader(String label, {double? width}) {
    var h = Text(
      label,
      style: const TextStyle(fontSize: 11),
    );
    return DataColumn(
        label: width != null
            ? SizedBox(
                width: width,
                child: h,
              )
            : Expanded(child: h));
  }

  _getTableCell(String value, {double? width}) {
    var h = Text(
      value,
      style: const TextStyle(fontSize: 11),
    );
    return DataCell(width != null
        ? SizedBox(
            width: width,
            child: h,
          )
        : Expanded(child: h));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, provider, child) {
        var items = provider.cartItems;
        return AppBaseTabScreen(
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addUpdateItem(null),
            child: const Icon(Icons.add),
          ),
          child:items.isNotEmpty ? SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DataTable(columnSpacing: 14, columns: [
                  _getTableHeader("Revenue"),
                  _getTableHeader("Quantity", width: 50),
                  _getTableHeader("Amount", width: 50),
                  _getTableHeader("Total", width: 50),
                ], rows: [
                  ...items.map((e) {
                    return DataRow(cells: [
                      _getTableCell(e.revenueSource.name),
                      _getTableCell(e.quantity.toString(), width: 50),
                      _getTableCell(currency.format(e.amount), width: 50),
                      _getTableCell(currency.format(e.amount * e.quantity),
                          width: 50),
                    ]);
                  }).toList(),
                  DataRow(cells: [
                    DataCell(Container()),
                    DataCell(Container()),
                    const DataCell(Text(
                      "Total",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    )),
                    DataCell(Text(
                        currency.format(items
                            .map((e) => e.amount * e.quantity)
                            .fold(0.0, (value, next) => value + next)),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)))
                  ])
                ]),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 32),
                    child: AppButton(onPress: () {
                      _collectCash();
                    },
                        label: 'Print Receipt'),
                  )
              ],
            ),
          ) : const Center(child: Text("Cart is Empty"),),
        );
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
              ],
            )
          ],
        );
      },
    );
    if (result == CartAction.addToCart) {
      _addToCart();
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
