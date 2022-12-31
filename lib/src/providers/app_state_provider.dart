import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:zanmutm_pos_client/src/models/device_info.dart';
import 'package:zanmutm_pos_client/src/models/financial_year.dart';
import 'package:zanmutm_pos_client/src/models/pos_configuration.dart';
import 'package:zanmutm_pos_client/src/models/revenue_source.dart';
import 'package:zanmutm_pos_client/src/models/user.dart';

class AppStateProvider with ChangeNotifier {
  bool isAuthenticated = false;
  bool sessionHasBeenFetched = false;
  bool configurationHasBeenLoaded = false;
  User? user;
  PosConfiguration? posConfiguration;
  FinancialYear? financialYear;
  AppDeviceInfo? deviceInfo;
  List<RevenueSource> revenueSource = List.empty(growable: false);
  double tabDx = 1.0; // To control tab navigation

  static final AppStateProvider _instance = AppStateProvider._();
  factory AppStateProvider() => _instance;
  AppStateProvider._();

  void sessionFetched(User? sessionUser)  {
    user = sessionUser;
    isAuthenticated = sessionUser != null;
      sessionHasBeenFetched = true;
      notifyListeners();
  }

  void setTabDirection(double dir) {
    tabDx = dir;
    notifyListeners();
  }

  void setDeviceInfo(AppDeviceInfo info) {
    deviceInfo = info;
    notifyListeners();
  }

  void setAuthenticated(User loggedInUser)  {
    isAuthenticated = true;
    sessionHasBeenFetched = true;
    user = loggedInUser;
    notifyListeners();
  }

  void userLoggedOut() async {
    isAuthenticated = false;
    sessionHasBeenFetched = true;
    notifyListeners();
  }

  void setFinancialYear(FinancialYear? fy)  {
    financialYear = fy;
    notifyListeners();
  }

  void setRevenueSources(List<RevenueSource>? sources) {
    if (sources != null) {
      revenueSource = sources;
      notifyListeners();
    }
  }

  void setPosConfig(PosConfiguration? config) {
    posConfiguration = config;
    notifyListeners();
  }

  void setConfigLoaded() {
    configurationHasBeenLoaded = true;
    notifyListeners();
  }

}

final appStateProvider = AppStateProvider();
