import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/services/financial_year_service.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_detail_card.dart';
import 'package:zanmutm_pos_client/src/widgets/app_messages.dart';

class FinancialYearConfigScreen extends StatefulWidget {
  const FinancialYearConfigScreen({Key? key}) : super(key: key);

  @override
  State<FinancialYearConfigScreen> createState() => _FinancialYearConfigScreenState();
}

class _FinancialYearConfigScreenState extends State<FinancialYearConfigScreen> {

  bool _isLoading = false;

  @override
  void initState() {
      _loadFinancialYear();
      super.initState();
  }

  _loadFinancialYear() async {
      setState(() {
        _isLoading= true;
      });
      try {
        debugPrint('About to fetch');
        await FinancialYearService().fetchFromApi();
      debugPrint('Fetch completed');
      setState(() {
          _isLoading = false;
        });
      } catch(e) {
        setState(() {
          _isLoading = false;
        });
        AppMessages.showError(context, e.toString());
     }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
  builder: (context, provider, child) {
  return AppBaseScreen(
       isLoading: _isLoading,
        appBar: AppBar(title: const Text('Financial Year Configuration'),),
        child: AppDetailCard(
          title: "Financial Year",
          data: provider.financialYear != null ? provider.financialYear!.toJson() : null,
          columns: [
            AppDetailColumn(header: 'Name', value: 'name'),
            AppDetailColumn(header: 'startDate', value: 'startDate'),
            AppDetailColumn(header: 'End date', value: 'endDate'),
          ],
          actionBuilder: (data) =>IconButton(
              splashRadius: 24,
              onPressed: () => _loadFinancialYear(), icon: const Icon(Icons.sync)),
        ));
  },
);
  }
}
