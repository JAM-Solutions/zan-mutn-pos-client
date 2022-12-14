import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/app.dart';
import 'package:zanmutm_pos_client/src/db/db.dart';
import 'package:zanmutm_pos_client/src/providers/auth_provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await DbProvider().migrate();
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<AppStateProvider>(create: (_) => appStateProvider),
      ],
    child: App(),));
}
