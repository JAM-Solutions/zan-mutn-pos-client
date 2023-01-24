import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/models/device_info.dart';
import 'package:zanmutm_pos_client/src/models/user.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/providers/device_info_provider.dart';
import 'package:zanmutm_pos_client/src/providers/financial_year_provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_configuration_provider.dart';
import 'package:zanmutm_pos_client/src/providers/revenue_source_provider.dart';
import 'package:zanmutm_pos_client/src/routes/app_routes.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({Key? key}) : super(key: key);

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  User? _user;
  AppDeviceInfo? _device;

  @override
  void initState() {
    super.initState();
    _user = context.read<AppStateProvider>().user;
    _device = context.read<DeviceInfoProvider>().deviceInfo;
    Future.delayed(Duration.zero, () => _loadAllConfigs());
  }

  _loadAllConfigs() {
    context.read<PosConfigurationProvider>().fetchPosConfig(_device);
    context.read<FinancialYearProvider>().fetchFinancialYear();
    context
        .read<RevenueSourceProvider>()
        .fetchRevenueSource(_user?.taxCollectorUuid);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<PosConfigurationProvider, FinancialYearProvider,
        RevenueSourceProvider>(
      builder:
          (context, posConfigProvider, fyProvider, revSourceProvider, child) {
        return AppBaseScreen(
          appBar: AppBar(
            title: const Text('Configurations'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go(AppRoute.dashboardTab),
            ),
          ),
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.point_of_sale_outlined),
                title: const Text('Pos Configuration'),
                subtitle: posConfigProvider.posConfigIsLoading
                    ? const LinearProgressIndicator()
                    : Text(
                        'Last update: ${posConfigProvider.posConfiguration?.lastUpdate ?? ''}'),
                trailing: posConfigProvider.posConfiguration != null
                    ? const Icon(Icons.verified, color: Colors.green)
                    : const Icon(
                        Icons.warning_rounded,
                        color: Colors.redAccent,
                      ),
                onTap: () => context.push(AppRoute.posConfig),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Financial Year Configuration'),
                subtitle: fyProvider.fyIsLoading
                    ? const LinearProgressIndicator()
                    : Text(
                        'Last update: ${fyProvider.financialYear?.lastUpdate ?? ''}'),
                trailing: fyProvider.financialYear != null
                    ? const Icon(Icons.verified, color: Colors.green)
                    : const Icon(
                        Icons.warning_rounded,
                        color: Colors.redAccent,
                      ),
                onTap: () => context.push(AppRoute.financialYear),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.monetization_on_outlined),
                title: const Text('Revenue Configuration'),
                trailing:
                    Text(revSourceProvider.revenueSource.length.toString()),
                subtitle: revSourceProvider.revSourcesIsLoading
                    ? const LinearProgressIndicator()
                    : null,
                onTap: () => context.push(AppRoute.revenueSource),
              )
            ],
          ),
        );
      },
    );
  }
}
