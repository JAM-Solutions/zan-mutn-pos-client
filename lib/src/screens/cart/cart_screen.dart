import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/providers/cart_provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_config_provider.dart';
import 'package:zanmutm_pos_client/src/screens/cart/collection_summary_table.dart';
import 'package:zanmutm_pos_client/src/screens/dashboard/client_dialog.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_tab_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_messages.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum CartAction { cancel, collectCash, addToCart }

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late CartProvider _cartProvider;
  late AppLocalizations? language;

  @override
  void initState() {
    _cartProvider = Provider.of(context, listen: false);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    language = AppLocalizations.of(context);
    super.didChangeDependencies();
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
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CollectionSummaryTable(
                        items: items,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 32),
                        child: AppButton(
                            onPress: () {
                              _collectCash();
                            },
                            label:
                                '${language?.print ?? 'Print'} ${language?.receipt ?? 'Receipt'}'),
                      ),
                      const SizedBox(
                        height: 80,
                      )
                    ],
                  ),
                )
              : Center(
                  child: Text(language?.isEmpty ?? "No item"),
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
    await TaxPlayerDialog(context)
        .collectCash(_cartProvider.cartItems, _onError, _onSuccess);
  }

  _onSuccess(String message) {
    AppMessages.showSuccess(context, message);
  }

  _onError(String error) {
    AppMessages.showError(context, error);
    debugPrint(error);
  }
}
