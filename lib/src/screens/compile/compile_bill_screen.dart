import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/api/api.dart';
import 'package:zanmutm_pos_client/src/models/format_type.dart';
import 'package:zanmutm_pos_client/src/models/pos_charge.dart';
import 'package:zanmutm_pos_client/src/models/pos_configuration.dart';
import 'package:zanmutm_pos_client/src/models/pos_transaction.dart';
import 'package:zanmutm_pos_client/src/models/user.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_config_provider.dart';
import 'package:zanmutm_pos_client/src/services/pos_charge_service.dart';
import 'package:zanmutm_pos_client/src/services/pos_transaction_service.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_tab_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_detail_card.dart';
import 'package:zanmutm_pos_client/src/widgets/app_messages.dart';

class CompileBillScreen extends StatefulWidget {
  const CompileBillScreen({Key? key}) : super(key: key);

  @override
  State<CompileBillScreen> createState() => _CompileBillScreenState();
}

class _CompileBillScreenState extends State<CompileBillScreen> {
  bool _posConnected = true;
  bool _transactionSynced = false;
  bool _allTransactionsCompiled = false;
  bool _allBillsGenerated = false;

  String? _error;
  List<PosCharge> _charges = List.empty();
  late User? _user;
  List<PosTransaction> _unCompiled = List.empty(growable: true);

  @override
  void initState() {
    _user = Provider.of<AppStateProvider>(context, listen: false).user;
    _syncAndLoad();
    super.initState();
  }

  _syncAndLoad() async {
    await _syncTransaction();
    await _getUnCompiled();
  }

  //Sync all transaction saved locally in pos device
  _syncTransaction() async {
    try {
      bool synced = await posTransactionService.sync();
      setState(() => _transactionSynced = synced);
    } on NoInternetConnectionException {
      setState(() => _posConnected = false);
      return false;
    } on DeadlineExceededException {
      setState(() => _posConnected = false);
    } catch (e) {
      setState(() => _error = e.toString());
      debugPrint(e.toString());
    }
  }

  // Get all Un compiled transaction to generate Charge Summary
  _getUnCompiled() async {
    if (_transactionSynced) {
      try {
        List<PosTransaction> transaction =
            await posTransactionService.getUnCompiled(_user!.taxCollectorUuid!);
        setState(() => {
              _unCompiled = transaction,
              _allTransactionsCompiled = transaction.isEmpty
            });
        if (transaction.isEmpty) {
          _loadCharges();
        }
      } on NoInternetConnectionException {
        setState(() => _posConnected = false);
      } on DeadlineExceededException {
        setState(() => _posConnected = false);
      } catch (e) {
        setState(() => _error = e.toString());
        debugPrint(e.toString());
      }
    }
  }

  //This function send api request to backend to compile all pos un compiled transaction into
  // a single charge
  _compileTransactions() async {
    if (_transactionSynced) {
      setState(() => _allTransactionsCompiled = false);
      try {
        int? status =
            await posTransactionService.compile(_user!.taxCollectorUuid!);
        if (status == 200) {
          setState(() => _allTransactionsCompiled = true);
          _loadCharges();
        }
      } on NoInternetConnectionException {
        setState(() => _posConnected = false);
      } on DeadlineExceededException {
        setState(() => _posConnected = false);
      } catch (e) {
        setState(() => _error = e.toString());
        debugPrint(e.toString());
      }
    }
  }

  _loadCharges() async {
    try {
      List<PosCharge> charges =
          await posChargeService.getPendingCharges(_user!.taxCollectorUuid!);
      setState(
          () => {_charges = charges, _allBillsGenerated = _charges.isEmpty});
    } on NoInternetConnectionException {
      setState(() => _posConnected = false);
      return false;
    } on DeadlineExceededException {
      setState(() => _posConnected = false);
    } catch (e) {
      setState(() => _error = e.toString());
      debugPrint(e.toString());
    }
  }

  _generateBill() async {
    bool? confirmed = await AppMessages.appConfirm(
        context, 'Generate Bill', 'Are you sure you want to generate bill');
    if (confirmed == true) {
      try {
        await posChargeService.createBill(_user!.taxCollectorUuid!);
        _loadCharges();
      } catch (e) {
        debugPrint(e.toString());
        //Snack bar here
      }
    }
  }

  _retry() async {
    setState(() => {_posConnected = true, _error = null});
    if (!_transactionSynced) {
      _syncAndLoad();
      return;
    } else if (!_allTransactionsCompiled) {
      _compileTransactions();
      return;
    } else if (!_allBillsGenerated) {
      _loadCharges();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBaseTabScreen(
        child: Builder(builder: (_) {
      // If No internet connection or error has occured display
      // Message and retry button
      if (_error != null || !_posConnected) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error ?? 'No Internet connection'),
              AppButton(onPress: () => _retry(), label: 'Retry')
            ],
          ),
        );
      } else {
        // If transaction not synced return status showing synceing in progess
        if (!_transactionSynced) {
          return const Center(
            child: Text('Syncing Transactions....'),
          );
        } else if (_transactionSynced &&
            !_allTransactionsCompiled &&
            _unCompiled.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Column(
              children: [
                AppDetailCard(
                  title: 'Un compiled transactions',
                  elevation: 0,
                  data: {},
                  columns: [

                    AppDetailColumn(
                        header: 'Total Amount',
                        value: _unCompiled
                            .map((e) => e.amount * e.quantity)
                            .fold(0.0, (accum, subTotal) => accum + subTotal),
                      format: FormatType.currency
                        ),
                    AppDetailColumn(
                        header: 'Total Transactions', value: _unCompiled.length),
                  ],
                ),
                AppButton(
                    onPress: () => _compileTransactions(),
                    label: 'Compile Transactions')
              ],
            ),
          );
        } else if (_allTransactionsCompiled && !_allBillsGenerated) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                      itemBuilder: (BuildContext context, int idx) {
                        var item = _charges[idx];
                        return AppDetailCard(
                          title: '',
                          elevation: 0,
                          data: item.toJson(),
                          columns: [
                            AppDetailColumn(
                                header: 'Amount',
                                value: item.amount,
                                format: FormatType.currency),
                            AppDetailColumn(
                                header: 'Total Transaction',
                                value: item.transactions.length.toString()),
                          ],
                          actionBuilder: (_) => AppButton(
                            onPress: () => _generateBill(),
                            label:  'Generate Bill',
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int idx) {
                        return const SizedBox(
                          height: 4,
                        );
                      },
                      itemCount: _charges.length),
                ),
              ],
            ),
          );
        } else {
          return const Center(
            child: Text('No Pending transaction found'),
          );
        }
      }
    }));
  }
}
