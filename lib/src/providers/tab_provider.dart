import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zanmutm_pos_client/src/routes/app_routes.dart';
import 'package:zanmutm_pos_client/src/routes/app_tab_item.dart';

class TabProvider extends ChangeNotifier {
  int currentTabIndex = 0;
  double tabDx = 1.0; // To control tab navigation
  AppTabRoute currentTab = appRoute.getTabRoutes().elementAt(0);

  void gotToTab(BuildContext context, int index) {
    tabDx = currentTabIndex < index ? 1.0 : -10.0;
    currentTabIndex = index;
    currentTab = appRoute.getTabRoutes().elementAt(index);
    context.go(currentTab.path);
    notifyListeners();
  }
}

final tabProvider = TabProvider();

