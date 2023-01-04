import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:zanmutm_pos_client/src/models/financial_year.dart';
import 'package:zanmutm_pos_client/src/models/pos_configuration.dart';
import 'package:zanmutm_pos_client/src/models/revenue_source.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_config_provider.dart';
import 'package:zanmutm_pos_client/src/routes/app_routes.dart';
import 'package:zanmutm_pos_client/src/services/auth_service.dart';
import 'package:zanmutm_pos_client/src/services/device_info_service.dart';
import 'package:zanmutm_pos_client/src/services/financial_year_service.dart';
import 'package:zanmutm_pos_client/src/services/pos_config_service.dart';
import 'package:zanmutm_pos_client/src/screens/splash/splash_screen.dart';
import 'package:zanmutm_pos_client/src/services/revenue_config_service.dart';
import 'package:zanmutm_pos_client/src/theme/app_theme.dart';

import 'models/device_info.dart';
import 'models/user.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final GoRouter _router = AppRoutes().getRoutes();
  late AppStateProvider _appState;
  late PosConfigProvider _configProvider;

  @override
  void initState() {
    _appState = Provider.of<AppStateProvider>(context, listen: false);
    _configProvider = Provider.of<PosConfigProvider>(context, listen: false);
    initApp();

    super.initState();
  }

  Future<void> initApp() async {
    //Query and set device info
    DeviceInfoPlugin infoPlugin = DeviceInfoPlugin();
    AppDeviceInfo info = await DeviceInfoService().getInfo(infoPlugin);
    _configProvider.setDeviceInfo(info);
    //Query ang get user session
    User? user = await authService.getSession();
    _appState.sessionFetched(user);
    // Check if pos config fetched/exist from db
    PosConfiguration? posConfig = await posConfigService.queryFromDb(info.id);
    _configProvider.setPosConfig(posConfig);
    FinancialYear? year = await financialYearService.queryFromDb();
    _configProvider.setFinancialYear(year);
    List<RevenueSource> sources = await revenueConfigService.queryFromDb();
    _configProvider.setRevenueSources(sources);
    _appState.setConfigLoaded();
  }

  @override
  Widget build(BuildContext context) {
    ///Select state of authentication from auth provider
    ///If state is session loading return splash screen
    ///else return a router app
    return Consumer<AppStateProvider>(
      builder: (context, provider, child) {
        return provider.sessionHasBeenFetched &&
                provider.configurationHasBeenLoaded
            ? MaterialApp.router(
                debugShowCheckedModeBanner: false,
                routeInformationProvider: _router.routeInformationProvider,
                routeInformationParser: _router.routeInformationParser,
                routerDelegate: _router.routerDelegate,
                title: 'Zan-Mutm POS',
                localizationsDelegates: const [
                  FormBuilderLocalizations.delegate,
                ],
                theme: defaultTheme,
              )
            : const SplashScreen();
      },
    );
  }

  ///Clean listeners or any other resource when app is closed
  @override
  void dispose() {
    super.dispose();
  }
}
