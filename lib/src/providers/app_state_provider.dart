import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zanmutm_pos_client/src/models/device_info.dart';
import 'package:zanmutm_pos_client/src/models/financial_year.dart';
import 'package:zanmutm_pos_client/src/models/pos_configuration.dart';
import 'package:zanmutm_pos_client/src/models/user.dart';
import 'package:zanmutm_pos_client/src/utils/app_const.dart';

class AppStateProvider with ChangeNotifier {
  bool isAuthenticated = false;
  bool sessionHasBeenFetched = false;
  bool configurationHasBeenLoaded = false;
  User? user;
  PosConfiguration? posConfiguration;
  FinancialYear? financialYear;
  AppDeviceInfo? deviceInfo;


  Future<void> sessionFetched(User? user) async {

    isAuthenticated = user != null;
      sessionHasBeenFetched = true;
      notifyListeners();
  }

  Future<void> setDeviceInfo(AppDeviceInfo info) async {
    deviceInfo = info;
    notifyListeners();
  }

  Future<void> setAuthenticated(User loggedInUser) async {
    isAuthenticated = true;
    sessionHasBeenFetched = true;
    user = loggedInUser;
    notifyListeners();
  }

  void userLoggedOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConst.userKey);
    await prefs.remove(AppConst.tokenKey);
    isAuthenticated = false;
    sessionHasBeenFetched = true;
    notifyListeners();
  }

  void setFinancialYear(FinancialYear? fy)  {
    debugPrint(posConfiguration.toString());
    debugPrint(sessionHasBeenFetched.toString());
//    debugPrint(posConfiguration.toString());
    financialYear = fy;
    notifyListeners();
  }

  Future<void> setPosConfig(PosConfiguration? config) async {
    posConfiguration = config;
    configurationHasBeenLoaded = true;
    notifyListeners();
  }

}

final appStateProvider = AppStateProvider();
