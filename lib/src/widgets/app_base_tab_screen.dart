import 'package:flutter/material.dart';

class AppBaseTabScreen extends StatelessWidget {
  final Widget child;
  final Widget? floatingActionButton;

  const AppBaseTabScreen(
      {Key? key, required this.child, this.floatingActionButton})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: child,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
