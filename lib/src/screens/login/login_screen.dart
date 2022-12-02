import 'package:flutter/material.dart';
import 'package:zanmutm_pos_client/src/widgets/app_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScreen(
      child: Center(
        child: Text("Login works"),
      ),
    );
  }
}
