import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/listeners/message_listener.dart';
import 'package:zanmutm_pos_client/src/models/format_type.dart';
import 'package:zanmutm_pos_client/src/providers/financial_year_provider.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_detail_card.dart';

class FinancialYearConfigScreen extends StatefulWidget {
  const FinancialYearConfigScreen({Key? key}) : super(key: key);

  @override
  State<FinancialYearConfigScreen> createState() =>
      _FinancialYearConfigScreenState();
}

class _FinancialYearConfigScreenState extends State<FinancialYearConfigScreen> {
  @override
  void initState() {
    super.initState();
    if (context.read<FinancialYearProvider>().financialYear == null) {
      Future.delayed(Duration.zero,() => _loadFinancialYear());
    }
  }

  _loadFinancialYear() async {
    context.read<FinancialYearProvider>().fetchFinancialYear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FinancialYearProvider>(
      builder: (context, provider, child) {
        var fy = provider.financialYear;
        return MessageListener<FinancialYearProvider>(
          child: AppBaseScreen(
              isLoading: provider.fyIsLoading,
              floatingAction: FloatingActionButton(
                onPressed: () => _loadFinancialYear(),
                child: const Icon(Icons.refresh),
              ),
              appBar: AppBar(
                title: const Text('Financial Year Configuration'),
              ),
              child: Column(
                children: [
                  AppDetailCard(
                    title: "Financial Year",
                    data: provider.financialYear != null
                        ? provider.financialYear!.toJson()
                        : null,
                    columns: [
                      AppDetailColumn(header: 'Name', value: fy?.name),
                      AppDetailColumn(
                          header: 'startDate',
                          value: fy?.startDate,
                          format: FormatType.date),
                      AppDetailColumn(
                          header: 'End date',
                          value: fy?.endDate,
                          format: FormatType.date),
                    ],
                  ),
                ],
              )),
        );
      },
    );
  }
}
