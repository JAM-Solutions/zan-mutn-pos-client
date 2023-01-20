import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/app.dart';
import 'package:zanmutm_pos_client/src/db/db.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/providers/cart_provider.dart';
import 'package:zanmutm_pos_client/src/providers/login_provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_config_provider.dart';
import 'package:zanmutm_pos_client/src/providers/pos_status_provider.dart';
import 'package:zanmutm_pos_client/src/providers/tab_provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  await DbProvider().migrate();
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<AppStateProvider>(create: (_) => appStateProvider),
        ChangeNotifierProvider<PosConfigProvider>(create: (_) => posConfigProvider),
        ChangeNotifierProvider<TabProvider>(create: (_) => tabProvider),
        ChangeNotifierProvider<CartProvider>(create: (_) => cartProvider),
        ChangeNotifierProvider<PosStatusProvider>(create: (_) => posStatusProvider),
        ChangeNotifierProvider<LoginProvider>(create: (_) => LoginProvider(),lazy: true,),
      ],
    child: const App(),));
}
