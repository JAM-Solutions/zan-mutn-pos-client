import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/app.dart';
import 'package:zanmutm_pos_client/src/db/db.dart';
import 'package:zanmutm_pos_client/src/providers/providers.dart';
import 'package:zanmutm_pos_client/src/services/service.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  await DbProvider().migrate();
  registerServices();
  runApp(MultiProvider(
      providers: appProviders,
    child: const App(),));
}
