import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';

class AppUpdateScreen extends StatefulWidget {
  const AppUpdateScreen({Key? key}) : super(key: key);

  @override
  State<AppUpdateScreen> createState() => _AppUpdateScreenState();
}

class _AppUpdateScreenState extends State<AppUpdateScreen> {
  final String url =
      'http://102.214.45.28:8080/api/v1/pos-app-releases/download/latest';

  @override
  void initState() {
    super.initState();
  }

  _launchURL(String url) async {
    await launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, provider, child) {
        return AppBaseScreen(
            appBar: AppBar(
              title: Text("Software Update"),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Latest Version ${provider.latestVersion} ',
                      textAlign: TextAlign.center),
                  const SizedBox(
                    height: 24,
                  ),
                  Builder(builder: (_) {
                    if (provider.currentVersion != null &&
                        provider.latestVersion != null &&
                        provider.latestVersion!
                                .compareTo(provider.currentVersion!) >
                            0) {
                      return GestureDetector(
                        onTap: () {
                          _launchURL(url);
                        },
                        child: Text(
                          'Click to download new version: $url',
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      );
                    } else {
                      return Text(
                        "Already up to date wit version ${provider.currentVersion}",
                        textAlign: TextAlign.center,
                      );
                    }
                  })
                ],
              ),
            ));
      },
    );
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('app_update');
    super.dispose();
  }
}
