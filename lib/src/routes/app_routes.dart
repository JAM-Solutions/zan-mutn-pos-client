import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:zanmutm_pos_client/src/providers/auth_provider.dart';
import 'package:zanmutm_pos_client/src/screens/dashboard/dashboard_screen.dart';
import 'package:zanmutm_pos_client/src/screens/login/login_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_route_shell.dart';

abstract class AppRoutes {
  //Const variable for route path
  static const String dashboard = "/";
  static const String login = "/login";

  //Route mapping
  static final GoRouter router = GoRouter(
    //Listen to change of auth state from auth provider
    refreshListenable: authProvider,
    routes: [
      ShellRoute(
          builder: (context, state, child) => AppRouteShell(child: child),
          routes: <RouteBase>[
            GoRoute(
                path: AppRoutes.dashboard,
                builder: (BuildContext context, GoRouterState state) =>
                    const DashboardScreen()),
            GoRoute(
                path: AppRoutes.login,
                builder: (BuildContext context, GoRouterState state) =>
                    const LoginScreen()),
          ])
    ],
    //Check auth state and redirect to login if user not authenticated
    redirect: (context, state) {
      final loggedIn = authProvider.isAuthenticated;
      //If user is 
      final isLoginRoute = state.subloc == '/login';
      //If is state is not logged in return login
      if (!loggedIn) return isLoginRoute ? null : '/login';
      //Else return default router
      // TODO implement back to previous page before redirected
      if (isLoginRoute) return '/';
      return null;
    },
  );
}
