import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zanmutm_pos_client/src/providers/auth_provider.dart';
import 'package:zanmutm_pos_client/src/routes/app_tab_item.dart';
import 'package:zanmutm_pos_client/src/screens/dashboard/dashboard_screen.dart';
import 'package:zanmutm_pos_client/src/screens/login/login_screen.dart';
import 'package:zanmutm_pos_client/src/screens/payment/payment_screen.dart';
import 'package:zanmutm_pos_client/src/screens/pos_config/pos_config_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_route_shell.dart';

class AppRoutes {
  //Const variable for route path
  static const String dashboard = "/";
  static const String login = "/login";
  static const String posConfig = "/pos-config";

  static  const List<AppTabItem> tabs = [
   AppTabItem(
     icon: Icon(Icons.home),
     label: "Home",path: "/",
     widget:  DashboardScreen(),
   ),
   AppTabItem(
       icon: Icon(Icons.payment),
       label: "Payments",
       path: "/payment",
       widget: PaymentScreen()
   )
  ];

  final  rootNavigatorKey = GlobalKey<NavigatorState>();
  final _shellNavigatorKey = GlobalKey<NavigatorState>();


  //Route mapping
  GoRouter getRoutes() =>  GoRouter(
    //Listen to change of auth state from auth provider
    refreshListenable: authProvider,
    navigatorKey: rootNavigatorKey,
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => AppRouteShell(child: child),
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
          path: AppRoutes.posConfig,
          builder: (BuildContext context, GoRouterState state) =>
          const PosConfigScreen()),
    ],
    //Check auth state and redirect to login if user not authenticated
    redirect: (context, state) {
      final loggedIn = authProvider.isAuthenticated;
      final hasConfig = authProvider.posConfiguration != null;
      //If user is 
      final isLoginRoute = state.subloc == AppRoutes.login;
      final isConfigRoute = state.subloc == AppRoutes.posConfig;
      final toRoute = state.subloc;
      //If is state is not logged in return login
      if (!loggedIn) {
        return isLoginRoute ? null : AppRoutes.login;
      } else if(loggedIn && !hasConfig) {
        return isConfigRoute ? null : AppRoutes.posConfig;
      }
      //Else return default router
      // TODO implement back to previous page before redirected
      if (isLoginRoute) return '/';
      return toRoute;
    },
  );
}
