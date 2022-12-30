import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/api/api.dart';
import 'package:zanmutm_pos_client/src/models/pos_configuration.dart';
import 'package:zanmutm_pos_client/src/models/pos_transaction.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/services/pos_transaction_service.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_tab_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_messages.dart';

class CompileBillScreen extends StatefulWidget {
  const CompileBillScreen({Key? key}) : super(key: key);

  @override
  State<CompileBillScreen> createState() => _CompileBillScreenState();
}

class _CompileBillScreenState extends State<CompileBillScreen> {
  bool _transactionSynced = false;
  bool _posConnected = true;
  bool _billCompiled = false;
  String? _error;

  late PosConfiguration? _posConfig;
  List<PosTransaction> _unCompiled = List.empty(growable: true);

  @override
  void initState() {
    _posConfig =
        Provider.of<AppStateProvider>(context, listen: false).posConfiguration;
    _start();
    super.initState();
  }

  _start() async {
    await _syncTransaction();
    await _getUnCompiled();
  }

  _syncTransaction() async {
    try {
      bool synced = await posTransactionService.sync();
      setState(() {
        _transactionSynced = synced;
      });
    } on NoInternetConnectionException {
      setState(() {
        _posConnected = false;
      });
      return false;
    } on DeadlineExceededException {
      setState(() {
        _posConnected = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      debugPrint(e.toString());
    }
  }

  _getUnCompiled() async {
    if (_transactionSynced) {
      try {
        List<PosTransaction> transaction =
            await posTransactionService.getUnCompiled(_posConfig!.posDeviceId);
        debugPrint(transaction.length.toString());
        setState(() {
          _unCompiled = transaction;
          _billCompiled = transaction.isEmpty;
        });
      } catch (e) {
        setState(() {
          debugPrint(e.toString());
          _error = e.toString();
        });
      }
    }
  }

  _retry() async {
    setState(() {
      _posConnected = true;
      _error = null;
    });
    _start();
  }

  _compileBill() async {
    if (_transactionSynced) {
      setState(() {
        _billCompiled = false;
      });
      try {
        int? status = await posTransactionService.compile(_posConfig!.posDeviceId);
        if (status == 200) {
          setState(() {
            _billCompiled = true;
          });
        }
      } on NoInternetConnectionException {
        setState(() {
          _posConnected = false;
        });
        return false;
      } on DeadlineExceededException {
        setState(() {
          _posConnected = false;
        });
      } catch (e) {
        AppMessages.showError(context, e.toString());
        debugPrint(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBaseTabScreen(

        child: Builder(builder: (_) {
      if (!_transactionSynced && _posConnected) {
        return const Center(
          child: Text('Syncing Transactions....'),
        );
      } else if ((!_posConnected && !_transactionSynced)) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error ?? 'No Internet connection'),
              AppButton(onPress: () => _retry(), label: 'Retry')
            ],
          ),
        );
      } else if (_transactionSynced && _billCompiled && _unCompiled.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Total items: ${_unCompiled.length}'),
              Text('Total Amount: ${_unCompiled.length}'),
              AppButton(onPress: () => _compileBill(), label: 'Compile Bill')
            ],
          ),
        );
      } else {
        return const Center(
          child: Text('No transaction to compile'),
        );
      }
    }));
  }
}
