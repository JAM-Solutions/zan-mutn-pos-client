import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/listeners/message_listener.dart';
import 'package:zanmutm_pos_client/src/providers/revenue_collection_provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_configuration_provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_status_provider.dart';
import 'package:zanmutm_pos_client/src/screens/revenue_collection/revenue_items.dart';
import 'package:zanmutm_pos_client/src/utils/helpers.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_tab_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum OnAddAction { cancel, collectCash, addToCart }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late AppLocalizations? language;
  bool _gridView = true;

  @override
  void initState() {
    context.read<PosStatusProvider>().loadStatus();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    language = AppLocalizations.of(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PosConfigurationProvider, PosStatusProvider>(
      builder: (context, configProvider, statusProvider, child) {
        return MessageListener<RevenueCollectionProvider>(
          child: AppBaseTabScreen(
              floatingActionButton: FloatingActionButton(
                onPressed: () => setState(() => _gridView = !_gridView),
                child: Icon(_gridView ? Icons.list_alt : Icons.grid_view),
              ),
              child: Builder(builder: (context) {
                var offlineLimit =
                    configProvider.posConfiguration?.offlineLimit;
                var amountLimit = configProvider.posConfiguration?.amountLimit;

                if (offlineLimit != null &&
                    statusProvider.offlineTime >= offlineLimit) {
                  return _buildSync('Time', currency.format(offlineLimit), 'min');
                }
                if (amountLimit != null &&
                    statusProvider.totalCollection >= amountLimit) {
                  return _buildSync('Amount', currency.format(amountLimit), 'Tsh');
                }
                return Column(
                  children: [
                    _buildDashboard(
                        offlineLimit,
                        amountLimit,
                        statusProvider.totalCollection,
                        statusProvider.offlineTime),
                    Expanded(child: RevenueItems(gridView: _gridView)),
                  ],
                );
              })),
        );
      },
    );
  }

  _buildDashboard(double? offlineLimit, double? amountLimit,
      double totalCollection, int offLineTime) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatus(currency.format(totalCollection),
              language?.collection ?? 'Collection'),
          _buildStatus(currency.format((amountLimit ?? 0) - totalCollection),
              language?.amountBalance ?? 'Amount Balance'),
          _buildStatus(currency.format((offlineLimit ?? 0) - offLineTime),
              language?.timeBalance ?? 'Time Balance'),
        ],
      ),
    );
  }

  _buildStatus(dynamic status, String name) => Expanded(
      child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  status.toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      overflow: TextOverflow.ellipsis,
                      color: Colors.blueGrey),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.blueGrey,
                    )),
              ],
            ),
          )));

  _buildSync(String limit, String value, String type) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_rounded,
              size: 48,
            ),
            Text(
              'You have reach Offline $limit limit of $value $type please connect pos and sync transactions',
              textAlign: TextAlign.center,
            ),
            AppButton(
                onPress: () =>
                    context.read<PosStatusProvider>().syncTransactions(),
                label: 'Synchronize')
          ],
        ),
      );
}
