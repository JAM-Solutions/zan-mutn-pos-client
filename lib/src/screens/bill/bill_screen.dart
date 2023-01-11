import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/api/api.dart';
import 'package:zanmutm_pos_client/src/models/bill.dart';
import 'package:zanmutm_pos_client/src/models/format_type.dart';
import 'package:zanmutm_pos_client/src/models/pos_configuration.dart';
import 'package:zanmutm_pos_client/src/models/user.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_config_provider.dart';
import 'package:zanmutm_pos_client/src/services/bill_service.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_tab_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_detail_card.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({Key? key}) : super(key: key);

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  List<Bill> _bills = List.empty(growable: true);
  bool _posConnected = true;
  bool _isLoading = false;
  late PosConfiguration? _posConfig;
  late User? user;
  String? _error;

  @override
  void initState() {
    _posConfig =
        Provider.of<PosConfigProvider>(context, listen: false).posConfiguration;
    user = Provider.of<AppStateProvider>(context, listen: false).user;
    _loadPendingBills();
    super.initState();
  }

  _loadPendingBills() async {
    try {
      var result = await billService.getPendingBills(user!.taxPayerUuid!);
      setState(() => {_bills = result, _isLoading = false});
    } on NoInternetConnectionException {
      setState(() => {_posConnected = false, _isLoading = false});
      return false;
    } on DeadlineExceededException {
      setState(() => {_posConnected = false, _isLoading = false});
    } catch (e) {
      setState(() => {_isLoading = false, _error = e.toString()});
    }
  }

  _retry() async {
    setState(() => {_isLoading = true, _error = null});
    _loadPendingBills();
  }

  @override
  Widget build(BuildContext context) {
    return AppBaseTabScreen(child: Builder(builder: (_) {
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
        if (_bills.isNotEmpty) {
          return ListView.separated(
              itemBuilder: (BuildContext _, int index) {
                var item = _bills[index];
                return AppDetailCard(
                    elevation: 0,
                    title: (index+1).toString(),
                    data: item.toJson(),
                    columns: [
                      AppDetailColumn(
                          header: 'Amount',
                          value: item.amount,
                          format: FormatType.currency),
                      AppDetailColumn(
                          header: 'Control Number', value: item.controlNumber),
                      AppDetailColumn(
                          header: 'Due time',
                          value: item.dueTime?.toIso8601String(),
                          format: FormatType.date),
                      AppDetailColumn(
                          header: 'Expire On',
                          value: item.expireDate?.toIso8601String(),
                          format: FormatType.date)
                    ]);
              },
              separatorBuilder: (BuildContext _, int index) => const SizedBox(
                    height: 4,
                  ),
              itemCount: _bills.length);
        } else {
          return const Center(
            child: Text("No pending bills found"),
          );
        }
      }
    }));
  }
}
