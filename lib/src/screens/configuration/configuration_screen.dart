import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/models/user.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/providers/financial_year_provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_configuration_provider.dart';
import 'package:zanmutm_pos_client/src/providers/revenue_source_provider.dart';
import 'package:zanmutm_pos_client/src/routes/app_routes.dart';
import 'package:zanmutm_pos_client/src/services/auth_service.dart';
import 'package:zanmutm_pos_client/src/services/service.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_icon_button.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({Key? key}) : super(key: key);

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  User? _user;
  late AppStateProvider _appState;
  late PosConfigurationProvider _posConfigurationProvider;
  late FinancialYearProvider _financialYearProvider;
  late RevenueSourceProvider _revenueSourceProvider;

  @override
  void initState() {
    super.initState();
    _appState = context.read<AppStateProvider>();
    _posConfigurationProvider = context.read<PosConfigurationProvider>();
    _financialYearProvider = context.read<FinancialYearProvider>();
    _revenueSourceProvider = context.read<RevenueSourceProvider>();
    Future.delayed(Duration.zero, () => _loadAllConfigs());
  }

  _loadAllConfigs() async {
    _user = _appState.user;
    await _financialYearProvider.fetchFinancialYear();
    await _posConfigurationProvider.fetchPosConfig(_user!.taxCollectorUuid!);
    await _revenueSourceProvider.fetchRevenueSource(_user!.taxCollectorUuid!);
    bool isConfigured = _posConfigurationProvider.posConfiguration != null &&
        _revenueSourceProvider.revenueSource.isNotEmpty &&
        _financialYearProvider.financialYear != null;
    _appState.setConfigLoaded(isConfigured: isConfigured);
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
            actions: [
              AppIconButton(
                  onPressed: () => getIt<AuthService>().logout(),
                  icon: Icons.logout),
            ],
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
              ),
              const Divider(),
              ListTile(
                title: const Text("Logout"),
                leading: const Icon(Icons.logout_sharp),
                onTap: () {
                  context.push(AppRoute.logout);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
