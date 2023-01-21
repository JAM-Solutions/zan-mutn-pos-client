import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/listeners/message_listener.dart';
import 'package:zanmutm_pos_client/src/providers/cart_provider.dart';
import 'package:zanmutm_pos_client/src/providers/revenue_collection_provider.dart';
import 'package:zanmutm_pos_client/src/screens/revenue_collection/collection_summary_table.dart';
import 'package:zanmutm_pos_client/src/screens/revenue_collection/collect_cash_dialog.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_tab_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
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
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        var items = cartProvider.cartItems;
        return MessageListener<RevenueCollectionProvider>(
          child: AppBaseTabScreen(
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
    await CollectCashDialog(context).collectCash(_cartProvider.cartItems);
  }
}
