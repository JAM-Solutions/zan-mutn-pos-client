import 'package:flutter/material.dart';
import 'package:zanmutm_pos_client/src/app.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';

class FinancialYearConfigScreen extends StatefulWidget {
  const FinancialYearConfigScreen({Key? key}) : super(key: key);

  @override
  State<FinancialYearConfigScreen> createState() => _FinancialYearConfigScreenState();
}

class _FinancialYearConfigScreenState extends State<FinancialYearConfigScreen> {
  @override
  Widget build(BuildContext context) {
    return AppBaseScreen(
        appBar: AppBar(title: Text('Financial Year Confiration'),),
        child: Center(child: Text("Fy"),));
  }
}
