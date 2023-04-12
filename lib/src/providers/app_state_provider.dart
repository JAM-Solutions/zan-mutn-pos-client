import 'dart:developer';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zanmutm_pos_client/src/api/api.dart';
import 'package:zanmutm_pos_client/src/mixin/message_notifier_mixin.dart';
import 'package:zanmutm_pos_client/src/models/user.dart';
import 'package:zanmutm_pos_client/src/services/auth_service.dart';
import 'package:zanmutm_pos_client/src/services/service.dart';
import 'package:zanmutm_pos_client/src/utils/app_const.dart';

class AppStateProvider with ChangeNotifier, MessageNotifierMixin {
  String? currentVersion;
  String? latestVersion;
  bool isAuthenticated = false;
  bool isConfigured = false;
  bool sessionHasBeenFetched = false;
  bool configurationHasBeenLoaded = false;
  User? user;
  Locale locale = const Locale.fromSubtags(languageCode: 'sw');

  static final AppStateProvider _instance = AppStateProvider._();
  factory AppStateProvider() => _instance;

  AppStateProvider._();

  Future<void> sessionFetched(User? sessionUser) async {
    user = sessionUser;
    isAuthenticated = sessionUser != null;
    sessionHasBeenFetched = true;
    notifyListeners();
  }

  void switchLang(Locale locale_) {
    locale = locale_;
    notifyListeners();
  }

  void setAuthenticated(User loggedInUser) {
    isAuthenticated = true;
    sessionHasBeenFetched = true;
    user = loggedInUser;
    notifyListeners();
  }

  Future<void> userLoggedOut() async {
    await getIt<AuthService>().logout();
    debugPrint("logged out called");
    isAuthenticated = false;
    sessionHasBeenFetched = true;
    configurationHasBeenLoaded = true;
    isConfigured = false;
    notifyListeners();
  }

  void setConfigLoaded({required isConfigured}) {
    configurationHasBeenLoaded = true;
    this.isConfigured = isConfigured;
    notifyListeners();
  }

  void loadAppVersion() async {
    final PackageInfo appInfo = await PackageInfo.fromPlatform();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    currentVersion = appInfo.version;
    try{
     var resp = await Api().dio.get("/pos-app-releases/latest");
     if(resp.statusCode == 200) {
       latestVersion = resp.data['data'];
       if(latestVersion != null && currentVersion !=null && latestVersion!.compareTo(currentVersion!) > 0) {
         notifyInfo("New version $latestVersion! is available update");
         prefs.setString(AppConst.latestVersion, latestVersion!);
      }
     }
    } catch(e){
      latestVersion =  prefs.getString(AppConst.latestVersion);
    }
    notifyListeners();
  }
}

final appStateProvider = AppStateProvider();
