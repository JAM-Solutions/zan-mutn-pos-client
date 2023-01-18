import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppTabRoute {
  final String label;
  final String pageTitle;
  final Icon icon;
  final String path;
  final Widget page;

  const AppTabRoute(
      {required this.page,
      required this.label,
      required this.pageTitle,
      required this.icon,
      required this.path});
}
