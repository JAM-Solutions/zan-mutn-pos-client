import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/providers/currency_provider.dart';
import 'package:zanmutm_pos_client/src/providers/device_info_provider.dart';
import 'package:zanmutm_pos_client/src/providers/financial_year_provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_configuration_provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_status_provider.dart';
import 'package:zanmutm_pos_client/src/providers/revenue_collection_provider.dart';
import 'package:zanmutm_pos_client/src/providers/revenue_source_provider.dart';
import 'package:zanmutm_pos_client/src/routes/app_routes.dart';
import 'package:zanmutm_pos_client/src/services/auth_service.dart';
import 'package:zanmutm_pos_client/src/screens/splash/splash_screen.dart';
import 'package:zanmutm_pos_client/src/services/service.dart';
import 'package:zanmutm_pos_client/src/theme/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'models/user.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final GoRouter _router = AppRoute().getRoutes();
  late AppStateProvider _appState;
  late DeviceInfoProvider _deviceInfoProvider;
  late PosConfigurationProvider _posConfigurationProvider;
  late FinancialYearProvider _financialYearProvider;
  late RevenueSourceProvider _revenueSourceProvider;
  late CurrencyProvider _currencyProvider;

  @override
  void initState() {
    super.initState();
    _appState = context.read<AppStateProvider>();
    _deviceInfoProvider = context.read<DeviceInfoProvider>();
    _posConfigurationProvider = context.read<PosConfigurationProvider>();
    _financialYearProvider = context.read<FinancialYearProvider>();
    _revenueSourceProvider = context.read<RevenueSourceProvider>();
    _revenueSourceProvider = context.read<RevenueSourceProvider>();
    _currencyProvider = context.read<CurrencyProvider>();
    initApp();
  }

  Future<void> initApp() async {
    if (!mounted) return;
    User? user = await getIt<AuthService>().getSession();
    if (user == null) {
      _appState.userLoggedOut();
    } else {
      _appState.sessionFetched(user);
    }
    _appState.loadAppVersion();
    await _deviceInfoProvider.loadDevice();
    await _posConfigurationProvider
        .loadPosConfig(_deviceInfoProvider.deviceInfo);
    await _financialYearProvider.loadFinancialYear();
    await _revenueSourceProvider.loadRevenueSource(user?.taxCollectorUuid);
    await _currencyProvider.loadCurrencies();
    _appState.setConfigLoaded();
    Timer.periodic(const Duration(seconds: 10), (timer) {
      context.read<RevenueCollectionProvider>().backGroundSyncTransaction();
    });
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
                locale: provider.locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  FormBuilderLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
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
