import 'package:flutter/material.dart';
import 'package:zanmutm_pos_client/src/providers/generate_bill_provider.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_detail_card.dart';
import 'package:zanmutm_pos_client/src/models/format_type.dart';

class GenerateBillBuilder extends StatelessWidget {
  final GenerateBillProvider provider;
  final Widget child;

  const GenerateBillBuilder(
      {Key? key, required this.provider, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (_) {
      // If No internet connection or error has occured display
      // Message and retry button
      if (provider.retryError != null || !provider.posIsConnected) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(provider.retryError ?? 'No Internet connection',textAlign: TextAlign.center),
              AppButton(onPress: () => provider.retry(), label: 'Retry')
            ],
          ),
        );
      } else {
        // If transaction not synced return status showing synceing in progess
        if (!provider.transactionSynced) {
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(
                  width: 16,
                ),
                Text('Syncing Transactions....', textAlign: TextAlign.center)
              ],
            ),
          );
        } else if (provider.transactionSynced &&
            !provider.allTransactionsCompiled &&
            provider.taxCollectorUnCompiled.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Column(
              children: [
                AppDetailCard(
                  title: 'Un compiled transactions',
                  elevation: 1,
                  data: {},
                  columns: [
                    AppDetailColumn(
                        header: 'Total Transactions',
                        value: provider.taxCollectorUnCompiled.length),
                    AppDetailColumn(
                        header: 'Total Amount',
                        value: provider.taxCollectorUnCompiled
                            .map((e) => e.amount * e.quantity)
                            .fold(0.0, (accum, subTotal) => accum + subTotal),
                        format: FormatType.currency),
                  ],
                ),
                AppButton(
                    onPress: () => provider.compileTransactions(),
                    label: 'Compile Transactions')
              ],
            ),
          );
        } else if (provider.allTransactionsCompiled &&
            !provider.allBillsGenerated) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                      itemBuilder: (BuildContext context, int idx) {
                        var item = provider.taxCollectorCharges[idx];
                        return AppDetailCard(
                          title: 'Compiled Charge',
                          elevation: 0,
                          data: item.toJson(),
                          columns: [
                            AppDetailColumn(
                                header: 'Total Transaction',
                                value: item.transactions.length.toString()),
                            AppDetailColumn(
                                header: 'Amount',
                                value: item.amount,
                                format: FormatType.currency),
                          ],
                          actionBuilder: (_) => AppButton(
                            onPress: () => provider.generateBill(),
                            label: 'Generate Bill',
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int idx) {
                        return const SizedBox(
                          height: 4,
                        );
                      },
                      itemCount: provider.taxCollectorCharges.length),
                ),
              ],
            ),
          );
        } else {
          return child;
        }
      }
    });
  }
}
