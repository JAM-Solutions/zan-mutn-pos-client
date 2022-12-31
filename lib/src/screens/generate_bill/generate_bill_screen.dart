import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/models/pos_charge.dart';
import 'package:zanmutm_pos_client/src/models/user.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/services/pos_charge_service.dart';
import 'package:zanmutm_pos_client/src/utils/helpers.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_tab_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';

class GenerateBillScreen extends StatefulWidget {
  const GenerateBillScreen({Key? key}) : super(key: key);

  @override
  State<GenerateBillScreen> createState() => _GenerateBillScreenState();
}

class _GenerateBillScreenState extends State<GenerateBillScreen> {
  List<PosCharge> _charges = List.empty();
  String? _errorLoadCharges;

  @override
  void initState() {
    _loadCharges();
    super.initState();
  }

  _loadCharges() async {
    setState(() {
      _errorLoadCharges = null;
    });
    try {
      User? user = Provider.of<AppStateProvider>(context, listen: false).user;
      List<PosCharge> charges =
          await posChargeService.getPendingCharges(user!.taxPayerUuid!);
      setState(() {
        _charges = charges;
      });
    } catch (e) {
      debugPrint(e.toString());
      _errorLoadCharges = e.toString();
      setState(() {
        _errorLoadCharges = e.toString();
      });
    }
  }

  _generateBill(String chargeUuid)  async {
    try {
      await posChargeService.createBill(chargeUuid);
      _loadCharges();
    } catch(e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBaseTabScreen(child: Builder(builder: (_) {
      if (_errorLoadCharges != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorLoadCharges!),
              AppButton(onPress: () => _loadCharges(), label: 'Retry')
            ],
          ),
        );
      }
      return _charges.length > 0 ? Column(
        children: [
          const ListTile(
            dense: true,
            title: Text(
              "Select Charge to Generate Bill",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(
            thickness: 0.9,
          ),
          Expanded(
            child: ListView.separated(
                itemBuilder: (BuildContext context, int idx) {
                  return ListTile(
                    title: Text(currency.format(_charges[idx].amount)),
                    subtitle: Text(
                        '${_charges[idx].transactions.length.toString()} Transaction'),
                    trailing: TextButton(
                      child: const Text('Generate Bill'),
                      onPressed: () {
                        _generateBill(_charges[idx].uuid);
                      },
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int idx) {
                  return const Divider(
                    thickness: 0.9,
                  );
                },
                itemCount: _charges.length),
          ),
        ],
      ) : Center(
        child: Text("No charge found"),
      );
    }));
  }
}
