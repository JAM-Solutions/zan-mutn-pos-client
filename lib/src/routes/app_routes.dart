import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_config_provider.dart';
import 'package:zanmutm_pos_client/src/providers/tab_provider.dart';
import 'package:zanmutm_pos_client/src/routes/app_tab_item.dart';
import 'package:zanmutm_pos_client/src/screens/bill/bill_screen.dart';
import 'package:zanmutm_pos_client/src/screens/cart/cart_screen.dart';
import 'package:zanmutm_pos_client/src/screens/configuration/configuration_screen.dart';
import 'package:zanmutm_pos_client/src/screens/configuration/financial_year_screen.dart';
import 'package:zanmutm_pos_client/src/screens/configuration/revenue_config_screen.dart';
import 'package:zanmutm_pos_client/src/screens/dashboard/dashboard_screen.dart';
import 'package:zanmutm_pos_client/src/screens/generate_bill/generate_bill_screen.dart';
import 'package:zanmutm_pos_client/src/screens/login/login_screen.dart';
import 'package:zanmutm_pos_client/src/screens/configuration/pos_config_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_tab_navigation_shell.dart';

class AppRoute {
  static final AppRoute _instance = AppRoute._();

  factory AppRoute() => _instance;

  AppRoute._();

  //Const variable for route path
  static const String dashboardTab = "/";
  static const String cartTab = "/cart";

  // static const String compileBillTab = "/compile-bill";
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
          path: AppRoute.login,
          builder: (BuildContext context, GoRouterState state) =>
              const LoginScreen()),
      GoRoute(
          path: AppRoute.config,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (BuildContext context, GoRouterState state) =>
              const ConfigurationScreen()),
      GoRoute(
        path: AppRoute.posConfig,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) =>
            const PosConfigScreen(),
      ),
      GoRoute(
        path: AppRoute.financialYear,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) =>
            const FinancialYearConfigScreen(),
      ),
      GoRoute(
        path: AppRoute.revenueSource,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) =>
            const RevenueConfigScreen(),
      )
    ];
  }

  List<AppTabRoute> getTabRoutes() => const [
        AppTabRoute(
          icon: Icon(Icons.home),
          label: "Home",
          pageTitle: "Home",
          path: dashboardTab,
          page: DashboardScreen(),
        ),
        AppTabRoute(
          icon: Icon(Icons.shopping_cart),
          label: "Cart",
          pageTitle: "Collect Revenue",
          path: cartTab,
          page: CartScreen(),
        ),
        AppTabRoute(
            icon: Icon(Icons.compress),
            label: "Generate Bill",
            pageTitle: "Compile Transactions",
            path: generateBillTab,
            page: GenerateBillScreen()),
        AppTabRoute(
            icon: Icon(Icons.payment_sharp),
            label: "Bills",
            pageTitle: "Pay Bills",
            path: billTab,
            page: BillScreen()),
      ];

  //Route mapping
  GoRouter getRoutes() => GoRouter(
        //Listen to change of auth state from auth provider
        refreshListenable: appStateProvider,
        navigatorKey: _rootNavigatorKey,
        routes: [
          //Create router for tab navigation with up down transiotion
          ShellRoute(
              navigatorKey: _shellNavigatorKey,
              builder: (context, state, child) =>
                  AppTabNavigationShell(child: child),
              routes: <RouteBase>[
                ...getTabRoutes().map((e) => GoRoute(
                      path: e.path,
                      pageBuilder: (BuildContext context, GoRouterState state) {
                        return _buildTabTransition(state, e.page);
                      }, // builder: (BuildContext context, GoRouterState state) => e.widget,
                    )),
              ]),
          ...getAppRoutes()
        ],
        //Check login state and configuration and redirect to login or
        // config if user not authenticated or no config loaded
        redirect: (context, state) {
          var appState = Provider.of<AppStateProvider>(context, listen: false);
          var posConfigState =
              Provider.of<PosConfigProvider>(context, listen: false);
          final loggedIn = appState.isAuthenticated;
          //If user is
          final isLoginRoute = state.subloc == AppRoute.login;
          final isConfigRoute = state.subloc.contains(AppRoute.config) ||
              state.subloc.contains(AppRoute.financialYear) ||
              state.subloc.contains(AppRoute.posConfig) ||
              state.subloc.contains(AppRoute.revenueSource);
          final toRoute = state.subloc;
          //If is state is not logged in return login
          if (!loggedIn) {
            return isLoginRoute ? null : AppRoute.login;
          } else if (loggedIn && posConfigState.posConfiguration == null) {
            return isConfigRoute ? null : AppRoute.config;
          } else if (isLoginRoute && loggedIn) {
            return '/';
          } else {
            return null;
          }
        },
      );

  _buildTabTransition(GoRouterState state, Widget page) => CustomTransitionPage(
        key: state.pageKey,
        child: page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(
            0.0,
            context.select<TabProvider, double>((value) => value.tabDx),
          );
          const end = Offset.zero;
          const curve = Curves.ease;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
}

final appRoute = AppRoute();
