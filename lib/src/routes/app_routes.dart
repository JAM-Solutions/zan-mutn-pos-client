import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/app.dart';
import 'package:zanmutm_pos_client/src/models/building.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/providers/tab_provider.dart';
import 'package:zanmutm_pos_client/src/routes/app_tab_item.dart';
import 'package:zanmutm_pos_client/src/screens/bill/bill_screen.dart';
import 'package:zanmutm_pos_client/src/screens/buildings/add_household.dart';
import 'package:zanmutm_pos_client/src/screens/buildings/view_household.dart';
import 'package:zanmutm_pos_client/src/screens/configuration/configuration_screen.dart';
import 'package:zanmutm_pos_client/src/screens/configuration/financial_year_screen.dart';
import 'package:zanmutm_pos_client/src/screens/configuration/revenue_config_screen.dart';
import 'package:zanmutm_pos_client/src/screens/currency/currency_screen.dart';
import 'package:zanmutm_pos_client/src/screens/dashboard/dashboard_screen.dart';
import 'package:zanmutm_pos_client/src/screens/generate_bill/generate_bill_screen.dart';
import 'package:zanmutm_pos_client/src/screens/buildings/building_screen.dart';
import 'package:zanmutm_pos_client/src/screens/login/login_screen.dart';
import 'package:zanmutm_pos_client/src/screens/logout/logout_screen.dart';
import 'package:zanmutm_pos_client/src/screens/update/app_update_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_tab_navigation_shell.dart';
import '../screens/pos_config/pos_config_screen.dart';

class AppRoute {
  static final AppRoute _instance = AppRoute._();

  factory AppRoute() => _instance;

  AppRoute._();

  //Const variable for route path
  static const String dashboardTab = "/";
  static const String cartTab = "/cart";

  static const String generateBillTab = "/generate-bill";
  static const String cashCollection = "/cart";
  static const String billTab = "/bill";
  static const String login = "/login";
  static const String config = "/configs";
  static const String posConfig = "/pos-config";
  static const String financialYear = "/financial-year";
  static const String houseHold = "/house-Hold";
  static const String revenueSource = "/revenue-sources";
  static const String currency = "/currencies";
  static const String appUpdate = "/app-update";
  static const String logout = "/logout";
  static const String addHouseHold = "/add-household";
  static const String viewHouseHold = "/view-household";

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
        path: AppRoute.houseHold,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) =>
            const BuildingsScreen(),
      ),
      GoRoute(
        path: AppRoute.revenueSource,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) =>
            const RevenueConfigScreen(),
      ),
      GoRoute(
        path: AppRoute.currency,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) =>
            const CurrencyScreen(),
      ),
      GoRoute(
        path: AppRoute.appUpdate,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) =>
            const AppUpdateScreen(),
      ),
      GoRoute(
        path: AppRoute.logout,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) =>
            const LogoutScreen(),
      ),
      GoRoute(
          path: AppRoute.addHouseHold,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (BuildContext context, GoRouterState state) {
            Building building = state.extra as Building;
            return AddHouseHoldScreen(building: building);
          }),
      GoRoute(
          path: AppRoute.viewHouseHold,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (BuildContext context, GoRouterState state) {
            Building building = state.extra as Building;
            return ViewHouseHoldScreen(building: building);
          })
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

  Future? openDialogPage(Widget page) {
    return _rootNavigatorKey.currentState?.push(MaterialPageRoute(
        fullscreenDialog: true,
        settings: const RouteSettings(),
        builder: (context) => page));
  }

  void closeDialogPage(dynamic data) {
    _rootNavigatorKey.currentState!.pop(data);
  }
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
          var appState = context.read<AppStateProvider>();
          //If user is
          final isLoginRoute = state.subloc == AppRoute.login;
          final isLogout = state.subloc == AppRoute.logout;
          final isConfigRoute = state.subloc.contains(AppRoute.config);
          final toRoute = state.subloc;
          /**
           * If user not authenticated and route is not login rout then
           * return login route.
           * Else if user authenticated and configuration has been loaded but
           * POS not configured successfully then go to config route
           */
          if (!appState.isAuthenticated) {
            return isLoginRoute ? null : AppRoute.login;
          } else if(appState.isAuthenticated && isLogout) {
            return AppRoute.logout;
          } else if (appState.isAuthenticated &&
              appState.configurationHasBeenLoaded &&
              !appState.isConfigured) {
            return isConfigRoute ? null : AppRoute.config;
          } else if ((isLoginRoute || isConfigRoute) &&
              appState.isConfigured &&
              appState.isAuthenticated) {
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
