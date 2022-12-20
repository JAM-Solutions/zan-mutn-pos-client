import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/routes/app_tab_item.dart';
import 'package:zanmutm_pos_client/src/screens/configuration/configuration_screen.dart';
import 'package:zanmutm_pos_client/src/screens/configuration/financial_year_config_screen.dart';
import 'package:zanmutm_pos_client/src/screens/configuration/revenue_config_screen.dart';
import 'package:zanmutm_pos_client/src/screens/dashboard/dashboard_screen.dart';
import 'package:zanmutm_pos_client/src/screens/login/login_screen.dart';
import 'package:zanmutm_pos_client/src/screens/payment/payment_screen.dart';
import 'package:zanmutm_pos_client/src/screens/configuration/pos_config_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_tab_navigation_shell.dart';

class AppRoutes {
  //Const variable for route path
  static const String dashboard = "/";
  static const String collectCash = "/collect-cash";
  static const String compileBill = "/compile-bill";
  static const String login = "/login";
  static const String config = "/config";
  static const String configPos = "pos";
  static const String configFinancialYear = "fy";
  static const String configRevenue = "revenue";

  static  const List<AppTabItem> tabs = [
   AppTabItem(
     icon: Icon(Icons.home),
     label: "Home",path: dashboard,
     widget:  DashboardScreen(),
   ),
   AppTabItem(
       icon: Icon(Icons.payment),
       label: "Cash",
       path: collectCash,
       widget: PaymentScreen()
   ),
    AppTabItem(
       icon: Icon(Icons.collections),
       label: "Bill",
       path: collectCash,
       widget: PaymentScreen()
   )
  ];

  final  rootNavigatorKey = GlobalKey<NavigatorState>();
  final _shellNavigatorKey = GlobalKey<NavigatorState>();


  //Route mapping
  GoRouter getRoutes() =>  GoRouter(
    //Listen to change of auth state from auth provider
    refreshListenable: appStateProvider,
    navigatorKey: rootNavigatorKey,
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => AppTabNavigationShell(child: child),
          routes: <RouteBase>[
            ...tabs.map((e) => GoRoute(
              path: e.path,
              pageBuilder: (BuildContext context, GoRouterState state) {
                return CustomTransitionPage(
                  key: state.pageKey,
                  child: e.widget,
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    // Change the opacity of the screen using a Curve based on the the animation's
                    // value
                    return FadeTransition(
                      opacity:
                      CurveTween(curve: Curves.easeInOutCirc).animate(animation),
                      child: child,
                    );
                  },
                );
              },
              // builder: (BuildContext context, GoRouterState state) => e.widget,
            )),
          ]),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
          path: AppRoutes.login,
          builder: (BuildContext context, GoRouterState state) =>
          const LoginScreen()),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
          path: AppRoutes.config,
          builder: (BuildContext context, GoRouterState state) =>
          const ConfigurationScreen(),
          routes: [
            GoRoute(
              parentNavigatorKey: rootNavigatorKey,
              path: AppRoutes.configFinancialYear,
              builder: (BuildContext context, GoRouterState state) =>
              const FinancialYearConfigScreen(),),
            GoRoute(
              path: AppRoutes.configPos,
              builder: (BuildContext context, GoRouterState state) =>
              const PosConfigScreen(),),
            GoRoute(
              path: AppRoutes.configRevenue,
              builder: (BuildContext context, GoRouterState state) =>
              const RevenueConfigScreen(),)
          ]
      ),
    ],
    //Check auth state and redirect to login if user not authenticated
    redirect: (context, state) {
      final loggedIn = appStateProvider.isAuthenticated;
      final hasConfig = appStateProvider.posConfiguration != null;
      //If user is
      final isLoginRoute = state.subloc == AppRoutes.login;
      final isConfigRoute = state.subloc.contains(AppRoutes.config) ;
      final toRoute = state.subloc;
      //If is state is not logged in return login
      if (!loggedIn) {
        return isLoginRoute ? null : AppRoutes.login;
      } else if(loggedIn && !hasConfig) {
        return isConfigRoute ? null : AppRoutes.config;
      }
      else if (isLoginRoute && loggedIn ) {
         return '/';
      }
      else {
        return null;
      }
    },
  );
}
