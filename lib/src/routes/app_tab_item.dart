import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppTabItem {

  final String label;
  final String title;
  final Icon icon;
  final String path;
  final Widget widget;
  final List<GoRoute>? childRoutes;

  const  AppTabItem(  {required this.widget,required this.label,required this.title, required this.icon, required this.path, this.childRoutes});
}
