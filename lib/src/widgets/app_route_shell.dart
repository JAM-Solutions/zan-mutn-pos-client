import 'package:flutter/material.dart';

/// This widget a wrapper that can be used to provide common functionalities/feature
/// that can be applied to all routed pages
/// It accept child widget which is a router page
class AppRouteShell extends StatelessWidget {
  final Widget child;
  const AppRouteShell({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return child;
  }
}
