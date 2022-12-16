import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/routes/app_routes.dart';
import 'package:zanmutm_pos_client/src/services/auth_service.dart';
import 'package:zanmutm_pos_client/src/services/device_info_service.dart';
import 'package:zanmutm_pos_client/src/services/pos_config_service.dart';
import 'package:zanmutm_pos_client/src/screens/splash/splash_screen.dart';
import 'package:zanmutm_pos_client/src/theme/app_theme.dart';

import 'models/device_info.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final GoRouter _router = AppRoutes().getRoutes();
  late AppStateProvider _appState;
  @override
  void initState() {
    _appState = Provider.of<AppStateProvider>(context,listen: false);
    initApp();

    super.initState();
  }

  Future<void> initApp() async {
    DeviceInfoPlugin infoPlugin = DeviceInfoPlugin();
    AppDeviceInfo info = await DeviceInfoService().getInfo(infoPlugin);
    await _appState.setDeviceInfo(info);
    await authService.getSession();
    await configService.getConfiguration(info.id);
  }

  @override
  Widget build(BuildContext context) {
    ///Select state of authentication from auth provider
    ///If state is session loading return splash screen
    ///else return a router app
    return Selector<AppStateProvider, bool>(
        selector: ((_, authState) => authState.sessionHasBeenFetched),
        builder: (context, sessionHasBeenFetched, child) =>
        sessionHasBeenFetched
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
            : const SplashScreen());
  }

  ///Clean listeners or any other resource when app is closed
  @override
  void dispose() {
    super.dispose();
  }
}
