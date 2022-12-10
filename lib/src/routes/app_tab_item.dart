import 'package:flutter/material.dart';

class AppTabItem {

  final String label;
  final Icon icon;
  final String path;
  final Widget widget;

  const  AppTabItem( {required this.widget,required this.label, required this.icon, required this.path});
}