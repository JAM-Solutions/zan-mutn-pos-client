import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/models/cart_item.dart';
import 'package:zanmutm_pos_client/src/models/financial_year.dart';
import 'package:zanmutm_pos_client/src/models/pos_transaction.dart';
import 'package:zanmutm_pos_client/src/models/revenue_source.dart';
import 'package:zanmutm_pos_client/src/models/user.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/providers/cart_provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_config_provider.dart';
import 'package:zanmutm_pos_client/src/services/financial_year_service.dart';
import 'package:zanmutm_pos_client/src/services/pos_transaction_service.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_tab_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_form.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_hidden.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_integer.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_number.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_text.dart';
import 'package:zanmutm_pos_client/src/widgets/app_messages.dart';

enum OnAddAction { cancel, collectCash, addToCart }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _addItemForm = GlobalKey<FormBuilderState>();
  final _taxPayerForm = GlobalKey<FormBuilderState>();

  List<RevenueSource> sources = List.empty(growable: true);
  List<RevenueSource> allSources = List.empty(growable: true);
  TextEditingController controller = TextEditingController();
  late CartProvider _cartProvider;
  late PosConfigProvider _configProvider;
  late FinancialYear? _year;
  late User? _user;

  @override
  void initState() {
    _configProvider = Provider.of<PosConfigProvider>(context, listen: false);
    _configProvider.getBalance();
    _cartProvider = Provider.of(context, listen: false);
    _user = Provider.of<AppStateProvider>(context,listen: false).user;
    _loadYear();
    allSources = _configProvider.revenueSource;
    setState(() => sources = [...allSources]);
    super.initState();
  }

  ///Load financial year from api or db///
  _loadYear() async {
    _year = await financialYearService.fetchAndStore();
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
      var filtered = allSources.where(
              (element) => element.name.toLowerCase().contains(searchVal.toLowerCase()));
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
            Row(
              children: [
                // add to cart action if user want
                // to continue with adding more revenue sources
                Expanded(
                  child: AppButton(
                      label: 'Add to Cart',
                      onPress: () {
                        if (_addItemForm.currentState?.saveAndValidate() ==
                            true) {
                          Navigator.of(context).pop(OnAddAction.addToCart);
                        }
                      }),
                ),
                const SizedBox(
                  width: 8,
                ),
                //Collect cash action if user want to collection
                // cash for single revenue source
                Expanded(
                  child: AppButton(
                      label: 'Collect Cash',
                      onPress: () {
                        if (_addItemForm.currentState?.saveAndValidate() ==
                            true) {
                          Navigator.of(context).pop(OnAddAction.collectCash);
                        }
                      }),
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
  _addToCart() {
    Map<String, dynamic> formValues = _addItemForm.currentState!.value;
    CartItem item = CartItem.fromJson(formValues);
    _cartProvider.addItem(item);
  }

  //If user select collect cash from add item dialog
  // Open tax payer dialog after confirmation
  //
  _collectCash() async {
    bool? confirmed = await _openTaxPayerDialog();
    if (confirmed == true) {
      //get tax payer details from taxpayer form
      var taxPayerValues = _taxPayerForm.currentState!.value;

      List<CartItem> items = _cartProvider.cartItems;

      //Add last item to cart or single item when print single revenus source
      //Both multi item and single item added to card first before save and printed
      Map<String, dynamic> lastItemValue = _addItemForm.currentState!.value;
      CartItem lastCardItem = CartItem.fromJson(lastItemValue);
      _cartProvider.addItem(lastCardItem);

      //Use current time stamp as transaction id
      DateTime t = DateTime.now();
      String transactionId = t.toIso8601String();

      // Try printing receipt if fail it return print error
      String? printError = await _printReceipt();

      //For each cart items map then to PosTransaction object
      List<PosTransaction> posTxns = items
          .map((item) => PosTransaction.fromCashCollection(
          transactionId,
          transactionId,
          t,
          _configProvider.posConfiguration!.posDeviceId,
          item,
          _user!,
          taxPayerValues,
          _year!.id,
          printError == null,
          printError))
          .toList();
      try {
        // Save all pos transactions
        int result = await posTransactionService.saveAll(posTxns);
        // If saved successfully clear cart items and show message
        // If not show error message
        if (result > 0) {
          _cartProvider.clearItems();
          _onSuccess('Successfully');
        } else {
          //TODO should it clear cart when faild to save all transactiosn
          _onError('Something went wrong');
        }
      } catch (e) {
        // Catch other errors
        _onError(e.toString());
      }
    }
  }

  // Dialog to capture tax payer detail of present
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

  //TODO implement printing of receipt as  per pos brand and return null if success and error string if failed
  Future<String?> _printReceipt() async {
    return 'No implementation';
  }

  _onSuccess(String message) {
    AppMessages.showSuccess(context, message);
  }

  _onError(String error) {
    AppMessages.showError(context, error);
    debugPrint(error);
  }

}
