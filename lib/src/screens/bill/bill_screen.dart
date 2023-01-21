import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/listeners/message_listener.dart';
import 'package:zanmutm_pos_client/src/models/format_type.dart';
import 'package:zanmutm_pos_client/src/providers/bill_provider.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_tab_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_detail_card.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({Key? key}) : super(key: key);

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
        Duration.zero, () => context.read<BillProvider>().loadPendingBills());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BillProvider>(
      builder: (context, provider, child) {
        return MessageListener<BillProvider>(
          child: AppBaseTabScreen(child: Builder(builder: (_) {
            if (provider.retryError != null || !provider.posIsConnected) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(provider.retryError ?? 'No Internet connection'),
                    AppButton(onPress: () => provider.retry(), label: 'Retry')
                  ],
                ),
              );
            } else {
              if (provider.bills.isNotEmpty) {
                return ListView.separated(
                    itemBuilder: (BuildContext _, int index) {
                      var item = provider.bills[index];
                      return AppDetailCard(
                          elevation: 0,
                          title: (index + 1).toString(),
                          data: item.toJson(),
                          columns: [
                            AppDetailColumn(
                                header: 'Amount',
                                value: item.amount,
                                format: FormatType.currency),
                            AppDetailColumn(
                                header: 'Control Number',
                                value: item.controlNumber),
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
                    separatorBuilder: (BuildContext _, int index) =>
                        const SizedBox(
                          height: 4,
                        ),
                    itemCount: provider.bills.length);
              } else {
                return const Center(
                  child: Text("No pending bills found"),
                );
              }
            }
          })),
        );
      },
    );
  }
}
