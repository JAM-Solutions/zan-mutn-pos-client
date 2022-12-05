import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return AppBaseScreen(
      appBar: AppBar(title: Text("Payments"),),
        child: Center(child: TextButton(
      onPressed: () => context.pop(),
      child: Text("Back"),),));
  }
}
