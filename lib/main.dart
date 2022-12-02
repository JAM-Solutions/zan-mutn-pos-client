import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/app.dart';
import 'package:zanmutm_pos_client/src/providers/auth_provider.dart';

void main() {
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => authProvider),
      ],
    child: App(),));
}
