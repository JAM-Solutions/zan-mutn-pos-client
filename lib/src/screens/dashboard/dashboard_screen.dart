import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/models/cart_item.dart';
import 'package:zanmutm_pos_client/src/models/revenue_source.dart';
import 'package:zanmutm_pos_client/src/providers/cart_provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_config_provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_status_provider.dart';
import 'package:zanmutm_pos_client/src/providers/tab_provider.dart';
import 'package:zanmutm_pos_client/src/screens/dashboard/client_dialog.dart';
import 'package:zanmutm_pos_client/src/services/pos_transaction_service.dart';
import 'package:zanmutm_pos_client/src/utils/helpers.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_tab_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_card.dart';
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
  bool _gridView = true;

  @override
  void initState() {
    Provider.of<PosStatusProvider>(context, listen: false).loadStatus();
    _configProvider = Provider.of<PosConfigProvider>(context, listen: false);
    _cartProvider = Provider.of(context, listen: false);
    allSources = _configProvider.revenueSource;
    setState(() => sources = [...allSources]);
    super.initState();
  }

  _syncTransactions() async {
    try {
      await posTransactionService.sync();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PosConfigProvider, PosStatusProvider>(
      builder: (context, configProvider, statusProvider, child) {
        return AppBaseTabScreen(
            floatingActionButton: FloatingActionButton(
              onPressed: () => setState(() => _gridView = !_gridView),
              child: Icon(_gridView ? Icons.list_alt : Icons.grid_view),
            ),
            child: Builder(builder: (context) {
              var offlineLimit = configProvider.posConfiguration?.offlineLimit;
              var amountLimit = configProvider.posConfiguration?.amountLimit;

              if (offlineLimit != null &&
                  statusProvider.offlineTime >= offlineLimit) {
                return _buildSync('Time', currency.format(offlineLimit));
              }
              if (amountLimit != null &&
                  statusProvider.totalCollection >= amountLimit) {
                return _buildSync('Amount', currency.format(amountLimit));
              }
              return Column(
                children: [
                  _buildDashboard(
                      offlineLimit,
                      amountLimit,
                      statusProvider.totalCollection,
                      statusProvider.offlineTime),
                  _buildSearchInput(),
                  Expanded(
                      child: _gridView ? _buildGridView() : _buildListView()),
                ],
              );
            }));
      },
    );
  }

  _buildDashboard(double? offlineLimit, double? amountLimit,
      double totalCollection, int offLineTime) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatus(currency.format(totalCollection), 'Collection\n(Tsh)'),
          _buildStatus(currency.format((amountLimit ?? 0) - totalCollection),
              'Amount Balance\n(Tsh)'),
          _buildStatus(currency.format((offlineLimit ?? 0) - offLineTime),
              'Time Balance\n(min)'),
        ],
      ),
    );
  }

  _buildStatus(dynamic status, String name) => Expanded(
      child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  status.toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      overflow: TextOverflow.ellipsis,
                      color: Colors.blueGrey),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.blueGrey,
                    )),
              ],
            ),
          )));

  _buildSync(String limit, String value) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_rounded,
              size: 48,
            ),
            Text(
              'You have reach offline amount $limit of $value please connect pos and sync transactions',
              textAlign: TextAlign.center,
            ),
            AppButton(onPress: () => _syncTransactions(), label: 'Synchronize')
          ],
        ),
      );

  _buildSearchInput() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
        child: TextFormField(
          controller: controller,
          onChanged: (val) => _onSearch(val),
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
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
      );

  _buildAvatar(item) => CircleAvatar(
        backgroundColor: Colors.blueGrey,
        child: Text(
          item.name.substring(0, 1),
          style: const TextStyle(
              fontWeight: FontWeight.normal, color: Colors.white, fontSize: 18),
        ),
      );

  _buildTitle(RevenueSource item) => Text(
        item.name,
        style: const TextStyle(
            fontSize: 15, color: Colors.blueGrey, fontWeight: FontWeight.bold),
      );

  _buildSubTitle(RevenueSource item) => Text(
        '${currency.format(item.unitCost ?? 0)}/${item.unitName ?? ''}',
        style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
      );

  _buildListView() => ListView.separated(
        itemCount: sources.length,
        itemBuilder: (BuildContext _, int index) {
          var item = sources[index];
          return ListTile(
            leading: _buildAvatar(item),
            title: _buildTitle(item),
            trailing: _buildSubTitle(item),
            onTap: () => _addItem(item),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider();
        },
      );

  _buildGridView() => GridView(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 4, mainAxisSpacing: 4),
        children: sources
            .map((item) => InkWell(
                  onTap: () => _addItem(item),
                  child: Card(
                      elevation: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildAvatar(item),
                          const SizedBox(
                            height: 4,
                          ),
                          _buildTitle(item),
                          const SizedBox(
                            height: 2,
                          ),
                          _buildSubTitle(item)
                        ],
                      )),
                ))
            .toList(),
      );

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
    RevenueItem item = RevenueItem.fromJson(formValues);
    _cartProvider.addItem(item);
  }

  //If user select collect cash from add item dialog
  // Open tax payer dialog after confirmation
  //
  _collectCash() async {
    if (_cartProvider.cartItems.isNotEmpty) {
      await _addToCart();
      if (mounted) {
        Provider.of<TabProvider>(context, listen: false).gotToTab(context, 1);
      }
    } else {
      Map<String, dynamic> formValues = _addItemForm.currentState!.value;
      RevenueItem item = RevenueItem.fromJson(formValues);
      await TaxPlayerDialog(context).collectCash([item], _onError, _onSuccess);
    }
  }

  _onSuccess(String message) {
    if (!mounted) return;
    Provider.of<PosStatusProvider>(context, listen: false).loadStatus();
    AppMessages.showSuccess(context, message);
  }

  _onError(String error) {
    if (!mounted) return;
    AppMessages.showError(context, error);
    debugPrint(error);
  }
}
