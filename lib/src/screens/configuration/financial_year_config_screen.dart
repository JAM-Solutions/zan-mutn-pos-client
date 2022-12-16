import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_detail_card.dart';

class FinancialYearConfigScreen extends StatefulWidget {
  const FinancialYearConfigScreen({Key? key}) : super(key: key);

  @override
  State<FinancialYearConfigScreen> createState() => _FinancialYearConfigScreenState();
}

class _FinancialYearConfigScreenState extends State<FinancialYearConfigScreen> {

  _loadFinancialYear() async {

  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
  builder: (context, provider, child) {
  return AppBaseScreen(
        appBar: AppBar(title: const Text('Financial Year Configuration'),),
        child: AppDetailCard(
          title: "Pos Configuration",
          data: provider.posConfiguration != null ? provider.posConfiguration!.toJson() : null,
          columns: [
            AppDetailColumn(header: 'Device name', value: 'posDeviceName'),
            AppDetailColumn(header: 'Offline', value: 'offlineLimit'),
            AppDetailColumn(header: 'Amount Limit', value: 'amountLimit'),
          ],
          actionBuilder: (data) =>IconButton(
              splashRadius: 24,
              onPressed: () => _loadFinancialYear(), icon: const Icon(Icons.sync)),
        ));
  },
);
  }
}
