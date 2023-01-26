import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zanmutm_pos_client/src/models/user.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/providers/cart_provider.dart';
import 'package:zanmutm_pos_client/src/providers/tab_provider.dart';
import 'package:zanmutm_pos_client/src/routes/app_routes.dart';
import 'package:zanmutm_pos_client/src/routes/app_tab_item.dart';
import 'package:zanmutm_pos_client/src/widgets/app_drawer.dart';

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
  late AppLocalizations? language;

  @override
  void didChangeDependencies() {
    language = AppLocalizations.of(context);
    super.didChangeDependencies();
  }

  _switchLang() {
    Locale current = Localizations.localeOf(context);
    context.read<AppStateProvider>().switchLang(Locale.fromSubtags(
        languageCode: current.languageCode == 'en' ? 'sw' : 'en'));
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
            decoration: const BoxDecoration(color: Color(0xFFebebeb)),
          ))
        ],
      ),
      Consumer2<TabProvider, CartProvider>(
        builder: (context, tabProvider, cartProvider, child) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(_translateTabTitle(tabProvider.currentTab)),
              centerTitle: true,
              actions: [
                IconButton(
                    onPressed: () => _switchLang(),
                    icon: const Icon(Icons.translate_rounded))
              ],
            ),
            drawer: const AppDrawer(),
            body: Selector<AppStateProvider, User>(
              selector: (context, state) => state.user!,
              builder: (context, user, child) {
                return Column(
                  children: [
                    const SizedBox(
                      height: 8,
                    ),
                    Expanded(
                        child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                )),
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: widget.child)),
                  ],
                );
              },
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: tabProvider.currentTabIndex,
              type: BottomNavigationBarType.fixed,
              items: [
                ...appRoute.getTabRoutes().map((e) {
                  Widget icon = e.label.contains('Cart') &&
                          cartProvider.cartItems.isNotEmpty
                      ? Badge(
                          label:
                              Text(cartProvider.cartItems.length.toString()),
                          padding: const EdgeInsets.all(6),
                          child: e.icon,
                        )
                      : e.icon;
                  return BottomNavigationBarItem(
                      icon: icon, label: _translateTabLabel(e));
                })
              ],
              onTap: (int tabIndex) => tabProvider.gotToTab(context, tabIndex),
            ),
          );
        },
      ),
    ]);
  }

  _translateTabLabel(AppTabRoute tab) {
    switch (tab.path) {
      case AppRoute.dashboardTab:
        return language?.homeTab ?? tab.label;
      case AppRoute.cartTab:
        return language?.cartTab ?? tab.label;
      case AppRoute.generateBillTab:
        return language?.generateTab ?? tab.label;
      case AppRoute.billTab:
        return language?.billsTab ?? tab.label;
      default:
        return tab.label;
    }
  }

  _translateTabTitle(AppTabRoute tab) {
    switch (tab.path) {
      case AppRoute.dashboardTab:
        return language?.homeTab ?? tab.pageTitle;
      case AppRoute.cartTab:
        return language?.cartTab ?? tab.pageTitle;
      case AppRoute.generateBillTab:
        return language?.generateTab ?? tab.pageTitle;
      case AppRoute.billTab:
        return language?.billsTab ?? tab.pageTitle;
      default:
        return tab.pageTitle;
    }
  }
}
