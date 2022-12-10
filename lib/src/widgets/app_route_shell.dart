
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zanmutm_pos_client/src/routes/app_routes.dart';
import 'package:zanmutm_pos_client/src/routes/app_tab_item.dart';

/// This widget a wrapper that can be used to provide common functionalities/feature
/// that can be applied to all routed pages
/// It accept child widget which is a router page
class AppRouteShell extends StatefulWidget {
  final Widget child;
  const AppRouteShell({Key? key, required this.child}) : super(key: key);

  @override
  State<AppRouteShell> createState() => _AppRouteShellState();
}

class _AppRouteShellState extends State<AppRouteShell> {

  int _currentTabIndex = 0;

  _goToTab(BuildContext context, int index) {
    setState(() {
      _currentTabIndex = index;
    });
    AppTabItem tab = AppRoutes.tabs.elementAt(index);
    context.go(tab.path);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        items:  [
          ...AppRoutes.tabs.map((e) =>
              BottomNavigationBarItem(icon: e.icon,label: e.label)
          )
        ],
        onTap: (int tabIndex) =>_goToTab(context, tabIndex),
      ),
    );
  }
}
