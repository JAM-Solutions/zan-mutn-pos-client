import 'package:flutter/material.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBaseScreen(
      appBar: AppBar(title: const Text("Dasboard"),),
        child: const Center(child: Text("Dashboard"),));
  }
}
