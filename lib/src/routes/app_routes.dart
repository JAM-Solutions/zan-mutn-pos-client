import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/models/revenue_source.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/routes/app_tab_item.dart';
import 'package:zanmutm_pos_client/src/screens/bill/bill_screen.dart';
import 'package:zanmutm_pos_client/src/screens/cash-collection/cash_collection_screen.dart';
import 'package:zanmutm_pos_client/src/screens/cash-collection/cash_screen.dart';
import 'package:zanmutm_pos_client/src/screens/configuration/configuration_screen.dart';
import 'package:zanmutm_pos_client/src/screens/configuration/financial_year_screen.dart';
import 'package:zanmutm_pos_client/src/screens/configuration/revenue_config_screen.dart';
import 'package:zanmutm_pos_client/src/screens/dashboard/dashboard_screen.dart';
import 'package:zanmutm_pos_client/src/screens/login/login_screen.dart';
import 'package:zanmutm_pos_client/src/screens/configuration/pos_config_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_tab_navigation_shell.dart';

class AppRoutes {
  //Const variable for route path
  static const String dashboardTab = "/";
  static const String cashTab = "/cash";
  static const String compileBillTab = "/compile-bill";
  static const String cashCollection = "/cash-collection";
  static const String login = "/login";
  static const String config = "/configs";
  static const String posConfig = "/pos-config";
  static const String financialYear = "/financial-year";
  static const String revenueSource = "/revenue-sources";

  final _rootNavigatorKey = GlobalKey<NavigatorState>();
  final _shellNavigatorKey = GlobalKey<NavigatorState>();

  List<GoRoute> getAppRoutes() {
    return [
      GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: AppRoutes.login,
          builder: (BuildContext context, GoRouterState state) =>
              const LoginScreen()),
      GoRoute(
          path: AppRoutes.cashCollection,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (BuildContext context, GoRouterState state) {
            var revenueSource = state.extra as RevenueSource;
            return CashCollectionScreen(revenueSource: revenueSource);
          }),
      GoRoute(
          path: AppRoutes.config,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (BuildContext context, GoRouterState state) =>
              const ConfigurationScreen()),
      GoRoute(
        path: AppRoutes.posConfig,
        builder: (BuildContext context, GoRouterState state) =>
            const PosConfigScreen(),
      ),
      GoRoute(
        path: AppRoutes.financialYear,
        builder: (BuildContext context, GoRouterState state) =>
            const FinancialYearConfigScreen(),
      ),
      GoRoute(
        path: AppRoutes.revenueSource,
        builder: (BuildContext context, GoRouterState state) =>
            const RevenueConfigScreen(),
      )
    ];
  }

  static List<AppTabItem> tabRoutes = const [
    AppTabItem(
      icon: Icon(Icons.home),
      label: "Home",
      path: dashboardTab,
      widget: DashboardScreen(),
    ),
    AppTabItem(
      icon: Icon(Icons.money),
      label: "Cash",
      path: cashTab,
      widget: CashScreen(),
    ),
    AppTabItem(
        icon: Icon(Icons.collections),
        label: "Bill",
        path: cashTab,
        widget: BillScreen())
  ];

  //Route mapping
  GoRouter getRoutes() => GoRouter(
        //Listen to change of auth state from auth provider
        navigatorKey: _rootNavigatorKey,
        routes: [
          ShellRoute(
              navigatorKey: _shellNavigatorKey,
              builder: (context, state, child) =>
                  AppTabNavigationShell(child: child),
              routes: <RouteBase>[
                ...tabRoutes.map((e) => GoRoute(
                    path: e.path,
                    pageBuilder: (BuildContext context, GoRouterState state) {
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: e.widget,
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          // Change the opacity of the screen using a Curve based on the the animation's
                          // value
                          return FadeTransition(
                            opacity: CurveTween(curve: Curves.easeInOutCirc)
                                .animate(animation),
                            child: child,
                          );
                        },
                      );
                    },
                    routes: e.childRoutes ?? []
                    // builder: (BuildContext context, GoRouterState state) => e.widget,
                    )),
              ]),
          ...getAppRoutes()
        ],
        //Check auth state and redirect to login if user not authenticated
        redirect: (context, state) {
          debugPrint('**Called*****');

          var appState = Provider.of<AppStateProvider>(context, listen: false);
          final loggedIn = appState.isAuthenticated;
          //If user is
          final isLoginRoute = state.subloc == AppRoutes.login;
          final isConfigRoute = state.subloc.contains(AppRoutes.config) ||
              state.subloc.contains(AppRoutes.financialYear) ||
              state.subloc.contains(AppRoutes.posConfig) ||
              state.subloc.contains(AppRoutes.revenueSource);
          final toRoute = state.subloc;
          //If is state is not logged in return login
          if (!loggedIn) {
            return isLoginRoute ? null : AppRoutes.login;
          } else if (loggedIn && appState.posConfiguration == null) {
            return isConfigRoute ? null : AppRoutes.config;
          } else if (isLoginRoute && loggedIn) {
            return '/';
          } else {
            return null;
          }
        },
      );
}
