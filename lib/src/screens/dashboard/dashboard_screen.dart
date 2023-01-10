import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/models/cart_item.dart';
import 'package:zanmutm_pos_client/src/models/revenue_source.dart';
import 'package:zanmutm_pos_client/src/providers/cart_provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_config_provider.dart';
import 'package:zanmutm_pos_client/src/providers/tab_provider.dart';
import 'package:zanmutm_pos_client/src/screens/dashboard/client_dialog.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_tab_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_form.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_hidden.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_integer.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_number.dart';
import 'package:zanmutm_pos_client/src/widgets/app_messages.dart';

enum OnAddAction { cancel, collectCash, addToCart }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _addItemForm = GlobalKey<FormBuilderState>();

  List<RevenueSource> sources = List.empty(growable: true);
  List<RevenueSource> allSources = List.empty(growable: true);
  TextEditingController controller = TextEditingController();
  late CartProvider _cartProvider;
  late PosConfigProvider _configProvider;

  @override
  void initState() {
    _configProvider = Provider.of<PosConfigProvider>(context, listen: false);
    _configProvider.getBalance();
    _cartProvider = Provider.of(context, listen: false);
    allSources = _configProvider.revenueSource;
    setState(() => sources = [...allSources]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PosConfigProvider>(
      builder: (context, provider, child) {
        return AppBaseTabScreen(
            child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: controller,
                onChanged: (val) => _onSearch(val),
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(36),
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor)),
                    suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          controller.clear();
                          _onSearch(null);
                        })),
              ),
            ),
            // list of revenue sources
            //on on tap open add item dialog
            Expanded(
                child: ListView.builder(
                    itemCount: sources.length,
                    itemBuilder: (BuildContext _, int index) {
                      var item = sources[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(item.name.substring(0, 1)),
                        ),
                        title: Text(item.name),
                        subtitle: Text(item.gfsCode),
                        onTap: () => _addItem(item),
                      );
                    })),
          ],
        ));
      },
    );
  }

  //Filter revenue source when user type on search box or clear search
  _onSearch(String? searchVal) {
    if (searchVal != null && searchVal.isNotEmpty) {
      var filtered = allSources.where((element) =>
          element.name.toLowerCase().contains(searchVal.toLowerCase()));
      setState(() => sources = [...filtered]);
    } else {
      setState(() => sources = [...allSources]);
    }
  }

  ///Add item dialogi triggered by click revenue source
  _addItem(RevenueSource source) async {
    var result = await showDialog<OnAddAction?>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
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
            return SingleChildScrollView(
              child: AppForm(
                initialValue: {},
                formKey: _addItemForm,
                controls: [
                  AppInputHidden(
                    fieldName: 'revenueSource',
                    value: source.toJson(),
                  ),
                  AppInputInteger(
                    name: 'quantity',
                    label: "Quantity",
                    validators: [
                      FormBuilderValidators.required(
                          errorText: "Quantity is required"),
                    ],
                  ),
                  AppInputNumber(
                    name: 'amount',
                    label: "Amount",
                    validators: [
                      FormBuilderValidators.required(
                          errorText: "Amount is required"),
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
    //After add item dialog is closed
    if (result == OnAddAction.addToCart) {
      _addToCart();
    } else if (result == OnAddAction.collectCash) {
      _collectCash();
    }
  }

  //If user select add to cart from add item dialog
  // Get values from add item form and update cart state from cat provider
  _addToCart() async {
    Map<String, dynamic> formValues = _addItemForm.currentState!.value;
    CartItem item = CartItem.fromJson(formValues);
    _cartProvider.addItem(item);
  }

  //If user select collect cash from add item dialog
  // Open tax payer dialog after confirmation
  //
  _collectCash() async {
    await _addToCart();
    if (!mounted) return;
    if(_cartProvider.cartItems.length > 1) {
      Provider.of<TabProvider>(context,listen: false).gotToTab(context, 1);
    } else {
      await TaxPlayerDialog(context).collectCash(_onError, _onSuccess);
    }
  }

  _onSuccess(String message) {
    AppMessages.showSuccess(context, message);
  }

  _onError(String error) {
    AppMessages.showError(context, error);
    debugPrint(error);
  }
}
