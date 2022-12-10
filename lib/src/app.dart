import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:zanmutm_pos_client/src/providers/auth_provider.dart';
import 'package:zanmutm_pos_client/src/routes/app_routes.dart';
import 'package:zanmutm_pos_client/src/screens/splash/splash_screen.dart';
import 'package:zanmutm_pos_client/src/theme/app_theme.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final GoRouter _router = AppRoutes().getRoutes();

  @override
  void initState() {
    //Load session when app initialized
    Provider.of<AuthProvider>(context, listen: false).getSession();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ///Select state of authentication from auth provider
    ///If state is session loading return splash screen
    ///else return a router app
    return Selector<AuthProvider, bool>(
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
