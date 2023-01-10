import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/providers/cart_provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_config_provider.dart';
import 'package:zanmutm_pos_client/src/screens/dashboard/client_dialog.dart';
import 'package:zanmutm_pos_client/src/utils/helpers.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_tab_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_messages.dart';

enum CartAction { cancel, collectCash, addToCart }

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late CartProvider _cartProvider;

  @override
  void initState() {
    _cartProvider = Provider.of(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartProvider, PosConfigProvider>(
      builder: (context, cartProvider, configProvider, child) {
        var items = cartProvider.cartItems;
        return AppBaseTabScreen(
          floatingActionButton: FloatingActionButton(
            onPressed: () => _clearCart(),
            child: const Icon(Icons.delete),
          ),
          child: items.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SingleChildScrollView(
                      child: DataTable(columnSpacing: 14, columns: [
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
                            _getTableCell(
                                currency.format(e.amount * e.quantity),
                                width: 50),
                          ]);
                        }).toList(),
                        DataRow(cells: [
                          const DataCell(Text("")),
                          const DataCell(Text("")),
                          const DataCell(Text(
                            "Total",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          )),
                          DataCell(Text(
                              currency.format(items
                                  .map((e) => e.amount * e.quantity)
                                  .fold(0.0, (value, next) => value + next)),
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)))
                        ])
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 32),
                      child: AppButton(
                          onPress: () {
                            _collectCash();
                          },
                          label: 'Print Receipt'),
                    )
                  ],
                )
              : const Center(
                  child: Text("Cart is Empty"),
                ),
        );
      },
    );
  }

  _clearCart() {
    _cartProvider.clearItems();
  }

  _collectCash() async {
    if (!mounted) return;
    await TaxPlayerDialog(context).collectCash(_onError, _onSuccess);
  }

  _onSuccess(String message) {
    AppMessages.showSuccess(context, message);
  }

  _onError(String error) {
    AppMessages.showError(context, error);
    debugPrint(error);
  }

  _getTableHeader(String label, {double? width}) {
    var h = Text(
      label,
      style: const TextStyle(fontSize: 11),
    );
    return DataColumn(label: h);
  }

  _getTableCell(String value, {double? width}) {
    var h = Text(
      value,
      style: const TextStyle(fontSize: 11),
    );
    return DataCell(h);
  }
}
