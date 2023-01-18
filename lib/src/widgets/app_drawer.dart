import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/models/user.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/routes/app_routes.dart';
import 'package:zanmutm_pos_client/src/services/auth_service.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late User? _user;

  @override
  void initState() {
    _user = context.read<AppStateProvider>().user;
    super.initState();
  }

  Widget appMenuItem(IconData iconData, String label, String route) => ListTile(
      leading: Icon(
        iconData,
        color: Theme.of(context).primaryColor,
      ),
      title: Text(
        label,
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
      onTap: () {
        Navigator.pop(context);
        context.push(route);
      });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 3;
    return Drawer(
        backgroundColor: Colors.white,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(
                      // height: width,
                      width: width,
                      image: const AssetImage('assets/images/logo.jpeg')),
                  const SizedBox(height: 4),
                  Text(
                    "${_user?.firstName} ${_user?.lastName ?? ''}",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 4),
                  Text(_user?.adminHierarchyName ?? '')
                ],
              ),
            ),
          ),
          const Divider(),
          const SizedBox(
            height: 16,
          ),
          Expanded(
              child: Column(
            children: [
              appMenuItem(
                  Icons.settings, 'Pos Configuration', AppRoute.posConfig),
              appMenuItem(Icons.money, 'Revenue Source Config',
                  AppRoute.revenueSource),
              appMenuItem(Icons.calendar_month, 'Financial year',
                  AppRoute.financialYear),
            ],
          )),
          ListTile(
            title: const Text("Logout"),
            leading: const Icon(Icons.logout_sharp),
            onTap: () => authService.logout(),
          ),
        ]));
  }
}
