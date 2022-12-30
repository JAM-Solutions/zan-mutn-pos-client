import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/routes/app_routes.dart';
import 'package:zanmutm_pos_client/src/routes/app_tab_item.dart';

/// This widget a wrapper for tabs
/// that can be applied to all routed pages
/// It accept child widget which is a router page
class AppTabNavigationShell extends StatefulWidget {
  final Widget child;

  const AppTabNavigationShell({Key? key, required this.child})
      : super(key: key);

  @override
  State<AppTabNavigationShell> createState() => _AppTabNavigationShellState();
}

class _AppTabNavigationShellState extends State<AppTabNavigationShell> {
  int _currentTabIndex = 0;
  AppTabItem _currentTab = AppRoutes.tabRoutes.elementAt(0);

  _goToTab(BuildContext context, int index) {
    Provider.of<AppStateProvider>(context, listen: false)
        .setTabDirection(_currentTabIndex < index ? 1.0 : -10.0);
    setState(() {
      _currentTabIndex = index;
      _currentTab = AppRoutes.tabRoutes.elementAt(index);
    });
    context.go(_currentTab.path);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          ),
          Expanded(
              child: Container(
            decoration:const BoxDecoration(
              color: Color(0xFFebebeb)
            ),
          ))
        ],
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(_currentTab.label),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              height: 110,
              margin: const EdgeInsets.symmetric(horizontal: 18),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:BorderRadius.only(
                    topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                )
              ),
              child: Column(
                children: [
                  Expanded(child: Row()),
                  const Divider(height: 0,thickness: 1,)
                ],
              ),
            ),
           Expanded(
               child: Container(
                 decoration: const BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.only(
                   )
                 ),
             margin: const EdgeInsets.symmetric(horizontal: 18),
               child: widget.child)) ,
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          items: [
            ...AppRoutes.tabRoutes.map((e) {
              Widget icon = e.label.contains('Cart') ? e.icon : e.icon;
              return BottomNavigationBarItem(icon: icon, label: e.label);
            })
          ],
          onTap: (int tabIndex) => _goToTab(context, tabIndex),
        ),
      ),
    ]);
  }
}
