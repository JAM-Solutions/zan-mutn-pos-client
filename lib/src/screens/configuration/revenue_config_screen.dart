import 'package:flutter/material.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';

class RevenueConfigScreen extends StatefulWidget {
  const RevenueConfigScreen({Key? key}) : super(key: key);

  @override
  State<RevenueConfigScreen> createState() => _RevenueConfigScreenState();
}

class _RevenueConfigScreenState extends State<RevenueConfigScreen> {
  @override
  Widget build(BuildContext context) {
    return AppBaseScreen(
      appBar: AppBar(title: Text('Revenue Source Configuration'),),
        child: Center(
          child: Text('Revenue'),
        ));
  }
}
