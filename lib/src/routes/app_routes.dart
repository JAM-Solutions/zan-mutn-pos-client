import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_config_provider.dart';
import 'package:zanmutm_pos_client/src/routes/app_tab_item.dart';
import 'package:zanmutm_pos_client/src/screens/bill/bill_screen.dart';
import 'package:zanmutm_pos_client/src/screens/cart/cart_screen.dart';
import 'package:zanmutm_pos_client/src/screens/compile/compile_bill_screen.dart';
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
  static const String cartTab = "/cart";
  static const String compileBillTab = "/compile-bill";
  static const String generateBillTab = "/generate-bill";
  static const String cashCollection = "/cart";
  static const String billTab = "/bill";
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
      title: "Dashboard",
      path: dashboardTab,
      widget: DashboardScreen(),
    ),
    AppTabItem(
      icon: Icon(Icons.shopping_cart),
      label: "Cart",
      title: "Collect Revenue",
      path: cartTab,
      widget: CartScreen(),
    ),
    AppTabItem(
        icon: Icon(Icons.compress),
        label: "Generate Bill",
        title: "Compile Transactions",
        path: compileBillTab,
        widget: CompileBillScreen()),
    AppTabItem(
        icon: Icon(Icons.payment_sharp),
        label: "Bills",
        title: "Pay Bills",
        path: billTab,
        widget: BillScreen()),
  ];

  //Route mapping
  GoRouter getRoutes() => GoRouter(
        //Listen to change of auth state from auth provider
        refreshListenable: appStateProvider,
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
                          var begin = Offset(0.0,
                              context.select<AppStateProvider, double>(
                                  (value) => value.tabDx),
                              );
                          const end = Offset.zero;
                          const curve = Curves.ease;

                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          return SlideTransition(
                            position: animation.drive(tween),
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
          var appState = Provider.of<AppStateProvider>(context, listen: false);
          var posConfigState =
              Provider.of<PosConfigProvider>(context, listen: false);
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
          } else if (loggedIn && posConfigState.posConfiguration == null) {
            return isConfigRoute ? null : AppRoutes.config;
          } else if (isLoginRoute && loggedIn) {
            return '/';
          } else {
            return null;
          }
        },
      );
}
