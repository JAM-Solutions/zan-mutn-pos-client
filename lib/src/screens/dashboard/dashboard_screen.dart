import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/providers/auth_provider.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);
 _logout(context) {
   Provider.of<AuthProvider>(context).userLoggedOut();
 }
  @override
  Widget build(BuildContext context) {
    return AppBaseScreen(
      appBar: AppBar(title: const Text("Dashboard"),),
        child: const Center(child: Text("Dashboard"),));
  }
}
