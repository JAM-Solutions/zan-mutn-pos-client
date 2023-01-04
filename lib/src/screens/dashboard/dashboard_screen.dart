import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_config_provider.dart';
import 'package:zanmutm_pos_client/src/utils/helpers.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_tab_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    Provider.of<PosConfigProvider>(context, listen: false).getBalance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PosConfigProvider>(
      builder: (context, provider, child) {
        return AppBaseTabScreen(
            child: Column(
          children: [
            ListTile(
              dense: true,
              title: const Text('Total Collection'),
              subtitle: const Text('Collection since last bill'),
              trailing: Text(
                currency.format(provider.totalCollection),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(
              height: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatus(
                    "Offline Balance",
                    Icons.account_balance_wallet_rounded,
                    currency.format(provider.offlineBalance)),
                const SizedBox(
                  width: 16,
                ),
                _buildStatus("Collection Balance",
                    Icons.account_balance_wallet_rounded, currency.format(0)),
                const SizedBox(
                  width: 16,
                ),
                _buildStatus("Offline Time Balance",
                    Icons.timelapse_outlined, currency.format(0)),
              ],
            )
          ],
        ));
      },
    );
  }

  _buildStatus(String title, IconData icon, String status) => Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 11, fontFamily: 'Roboto'),
              textAlign: TextAlign.center,
            ),
            Text(
              status,
              style: TextStyle(),
            )
          ],
        ),
      );
}
