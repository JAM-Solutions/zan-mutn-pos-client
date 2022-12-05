import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/providers/auth_provider.dart';
import 'package:zanmutm_pos_client/src/routes/app_routes.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);
 _logout(context) {
   Provider.of<AuthProvider>(context,listen: false).userLoggedOut();
 }

  Widget getTile(BuildContext context, IconData icon, String name, String link) {
    return GestureDetector(
      onTap: ()  => context.push(link),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column (
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 84,color: Theme.of(context).primaryColor,),
                const SizedBox(height: 12,),
                Text(name, style:  TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500),)
              ],
            ),
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return AppBaseScreen(
      appBar: AppBar(
        title: const Text("Zan-Mutm POS",),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () => _logout(context),
              icon: const Icon(Icons.logout))
        ],
      ),
        child: GridView.count(
          crossAxisCount: 2,
          children: [
            getTile(context,Icons.point_of_sale_rounded, 'Configuration', '/${AppRoutes.payment}'),
            getTile(context,Icons.receipt, 'Receipt', '/${AppRoutes.payment}'),
            getTile(context,Icons.payment, 'Payment', '/${AppRoutes.payment}'),
            getTile(context,Icons.wifi_protected_setup_outlined, 'Synchronise', '/${AppRoutes.payment}')
          ],
        )

    );
  }
}
