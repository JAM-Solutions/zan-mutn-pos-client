import 'package:flutter/material.dart';

class AppScreen extends StatelessWidget {
  final Widget child;

  const AppScreen({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    ));
  }
}
