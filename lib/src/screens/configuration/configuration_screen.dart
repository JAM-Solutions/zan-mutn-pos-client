import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_config_provider.dart';
import 'package:zanmutm_pos_client/src/routes/app_routes.dart';
import 'package:zanmutm_pos_client/src/services/financial_year_service.dart';
import 'package:zanmutm_pos_client/src/services/pos_config_service.dart';
import 'package:zanmutm_pos_client/src/services/revenue_config_service.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({Key? key}) : super(key: key);

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  late PosConfigProvider _configProvider;
  bool _posConfigIsLoading = false;
  bool _fyIsLoading = false;
  bool _revSourcesIsLoading = false;

  @override
  void initState() {
    _configProvider = Provider.of<PosConfigProvider>(context, listen: false);
    _checkAndLoadConfigs();
    super.initState();
  }

  _checkAndLoadConfigs() async {
    if (_configProvider.posConfiguration == null) {
      setState(() => _posConfigIsLoading = true);
      posConfigService.fetchAndStore(_configProvider.deviceInfo!.id).then(
          (value) {
        setState(() => _posConfigIsLoading = false);
        _configProvider.setPosConfig(value);
      }, onError: (e) {
        setState(() => _posConfigIsLoading = false);
      });
    }
    if (_configProvider.financialYear == null) {
      setState(() => _fyIsLoading = true);
      financialYearService.fetchAndStore().then((value) {
        setState(() => _fyIsLoading = false);
        _configProvider.setFinancialYear(value);
      }, onError: (e) {
        setState(() => _fyIsLoading = false);
      });
    }
    if (_configProvider.revenueSource.isEmpty) {
      setState(() => _revSourcesIsLoading = true);
      revenueConfigService.fetchAndStore().then((value) {
        setState(() => _revSourcesIsLoading = false);
        _configProvider.setRevenueSources(value);
      }, onError: (e) {
        setState(() => _revSourcesIsLoading = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PosConfigProvider>(builder: (context, appState, child) {
      return AppBaseScreen(
        appBar: AppBar(
          title: const Text('Configurations'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppRoutes.dashboardTab),
          ),
        ),
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.point_of_sale_outlined),
              title: const Text('Pos Configuration'),
              subtitle: _posConfigIsLoading
                  ? const LinearProgressIndicator()
                  : Text(
                      'Last update: ${appState.posConfiguration?.lastUpdate ?? ''}'),
              trailing: appState.posConfiguration != null
                  ? const Icon(Icons.verified, color: Colors.green)
                  : const Icon(
                      Icons.warning_rounded,
                      color: Colors.redAccent,
                    ),
              onTap: () => context.push(AppRoutes.posConfig),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Financial Year Configuration'),
              subtitle: _fyIsLoading
                  ? const LinearProgressIndicator()
                  : Text(
                      'Last update: ${appState.financialYear?.lastUpdate ?? ''}'),
              trailing: appState.financialYear != null
                  ? const Icon(Icons.verified, color: Colors.green)
                  : const Icon(
                      Icons.warning_rounded,
                      color: Colors.redAccent,
                    ),
              onTap: () => context.push(AppRoutes.financialYear),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.monetization_on_outlined),
              title: const Text('Revenue Configuration'),
              trailing: Text(_configProvider.revenueSource.length.toString()),
              subtitle:
                  _revSourcesIsLoading ? const LinearProgressIndicator() : null,
              onTap: () => context.push(AppRoutes.revenueSource),
            )
          ],
        ),
      );
    });
  }
}
